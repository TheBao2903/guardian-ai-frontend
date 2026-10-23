/// Microphone analysis and durable server-managed audio alerts. No audio storage.
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/home/presentation/widgets/danger_alert_sheet.dart';
import '../../../features/sos/data/models/emergency_session_model.dart';
import '../../../features/sos/presentation/providers/sos_controller.dart';
import '../location/location_service.dart';
import '../../network/api_client.dart';
import '../../constants/storage_keys.dart';
import 'danger_audio_manager.dart';
import 'detection/audio_analysis_queue.dart';
import 'detection/audio_analysis_input.dart';
import 'detection/server_audio_alert.dart';
import 'detection/alert_realtime_client.dart';
import 'detection/yamnet_classifier.dart';
import 'recording/audio_recorder_service.dart';
import 'recording/microphone_permission_service.dart';
import 'recording/ring_buffer.dart';

final dangerAudioApiClientProvider = Provider<ApiClient>(
    (ref) => ApiClient(storage: ref.read(secureStorageProvider)));
final dangerAudioRecorderProvider = Provider<AudioRecorderService>((ref) =>
    AudioRecorderService(
        ringBuffer: RingBuffer(
            config: const RingBufferConfig(
                sampleRate: 16000, maxDurationSeconds: 10))));

class DangerAudioNotifier extends StateNotifier<DangerAudioState>
    with WidgetsBindingObserver {
  DangerAudioNotifier(this._ref)
      : _api = _ref.read(dangerAudioApiClientProvider),
        _recorder = _ref.read(dangerAudioRecorderProvider),
        _classifier = _ref.read(audioClassifierProvider),
        super(const DangerAudioState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final Ref _ref;
  final ApiClient _api;
  final AudioRecorderService _recorder;
  final AudioClassifier _classifier;
  final _queue = AudioAnalysisQueue();
  Timer? _analysisTimer;
  AlertRealtimeClient? _alertRealtime;
  Future<bool>? _starting;
  bool _analyzing = false, _synchronizing = false;
  int _generation = 0;
  int _alertGeneration = 0;
  int _alertRevision = 0;
  String _streamId = '';
  String? _safetyCheckId;
  DateTime? _lastChunk;
  double? _latitude, _longitude;

  Future<void> checkPermission() => requestPermission();
  Future<bool> requestPermission() async {
    final granted = await _recorder.isAvailable();
    if (mounted) {
      state = state.copyWith(
          hasPermission: granted,
          permissionState: granted
              ? MicrophonePermissionState.granted
              : MicrophonePermissionState.denied);
    }
    return granted;
  }

  Future<bool> startMonitoring({String? safetyCheckInstanceId}) {
    _safetyCheckId = safetyCheckInstanceId;
    resumeAlerts();
    if (state.isMonitoring) return Future.value(true);
    return _starting ??= _start().whenComplete(() => _starting = null);
  }

  Future<bool> _start() async {
    final generation = ++_generation;
    try {
      if (!await requestPermission()) {
        if (mounted) {
          state = state.copyWith(
              error: 'Cần cấp quyền micro để nhận diện âm thanh.');
        }
        return false;
      }
      if (!mounted || generation != _generation) return false;
      _queue.clear();
      _streamId = '${DateTime.now().microsecondsSinceEpoch}-$generation';
      _lastChunk = DateTime.now();
      _recorder.onAudioChunk = (chunk) {
        _lastChunk = DateTime.now();
        _queue.add(chunk);
      };
      final started = await _recorder.start();
      if (!started) {
        throw StateError(_recorder.lastError ?? 'Không khởi động được micro.');
      }
      await _classifier.initialize();
      if (!mounted || generation != _generation) {
        await _recorder.stop();
        return false;
      }
      state = state.copyWith(isEnabled: true, isMonitoring: true);
      _analysisTimer?.cancel();
      _analysisTimer = Timer.periodic(
          const Duration(milliseconds: 100), (_) => unawaited(_tick()));
      unawaited(_updateLocation());
      return true;
    } catch (_) {
      await _recorder.stop();
      if (mounted && generation == _generation) {
        state = state.copyWith(
            isEnabled: false,
            isMonitoring: false,
            error: 'Micro chưa sẵn sàng. Kiểm tra quyền và thiết bị thu âm.');
      }
      return false;
    }
  }

  Future<void> _updateLocation() async {
    try {
      final pos = await _ref.read(locationServiceProvider).getCurrentLocation();
      if (mounted && pos != null) {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      }
    } catch (_) {/* Location must not block audio or SOS. */}
  }

  void resumeAlerts() {
    _alertRealtime ??= AlertRealtimeClient(
      url: AlertRealtimeClient.streamUrl(_api.dio.options.baseUrl),
      readToken: () =>
          _ref.read(secureStorageProvider).read(StorageKeys.accessToken),
      synchronize: syncCurrentAlert,
      onAlert: (data) async {
        if (data != null && mounted) {
          await _accept(ServerAudioAlert.fromJson(data));
        }
      },
    );
    _alertRealtime!.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _alertRealtime?.resume();
    }
  }

  Future<void> syncCurrentAlert() async {
    if (_synchronizing || !mounted) return;
    _synchronizing = true;
    final generation = _alertGeneration;
    final revision = _alertRevision;
    try {
      final response = await _api.get<dynamic>('/detection/alerts/current',
          options: Options(receiveTimeout: const Duration(seconds: 5)));
      final data = _unwrap(response.data);
      if (data is Map &&
          mounted &&
          generation == _alertGeneration &&
          revision == _alertRevision) {
        await _accept(ServerAudioAlert.fromJson(data));
      }
    } catch (_) {
      // Existing pending alert remains visible; the server still owns its timer.
    } finally {
      _synchronizing = false;
    }
  }

  dynamic _unwrap(dynamic response) => response is Map
      ? (response.containsKey('data') ? response['data'] : response)
      : null;

  Future<void> _tick() async {
    if (!mounted || !state.isMonitoring || _analyzing) return;
    if (!_recorder.isRecording) {
      state = state.copyWith(
          isMonitoring: false,
          error: _recorder.lastError ?? 'Micro đã dừng thu âm.');
      return;
    }
    if (_lastChunk != null &&
        DateTime.now().difference(_lastChunk!).inSeconds >= 3) {
      state = state.copyWith(
          error:
              'Chưa nhận được âm thanh từ micro. Kiểm tra thiết bị và quyền trình duyệt.');
      return;
    }
    final input = _queue.takeNext();
    if (input == null) return;
    if (DateTime.now().difference(input.capturedAt).inSeconds > 30) {
      state = state.copyWith(
          error: 'Âm thanh phân tích bị trễ. Kiểm tra kết nối backend.');
      return;
    }
    if (_ref.read(dangerAlertProvider).isShowing ||
        _ref.read(sosControllerProvider).isSosActive) {
      return;
    }
    final generation = _generation;
    _analyzing = true;
    try {
      ServerAudioAlert? alert;
      if (_classifier.isInitialized) {
        final results = await _classifier.classify(input.pcm);
        final screams =
            results.where((r) => r.classIndex == 11 && r.confidence >= .30);
        if (screams.isNotEmpty) {
          final response = await _api.post<dynamic>('/detection/alerts', data: {
            ..._context(input),
            'idempotency_key': '$_streamId:${input.endSample}',
            'event_type': 'SCREAM',
            'confidence': screams.first.confidence,
          });
          alert = ServerAudioAlert.fromJson(_unwrap(response.data) as Map);
        } else if (!_classifier.isInitialized) {
          alert = await _analyzeOnServer(input);
        }
      } else {
        alert = await _analyzeOnServer(input);
      }
      if (!mounted || generation != _generation || !state.isMonitoring) return;
      state = state.copyWith(
          error: _queue.droppedWindows > 0
              ? 'Phân tích không theo kịp micro. Kiểm tra kết nối backend.'
              : null);
      if (alert != null) await _accept(alert);
    } catch (_) {
      if (mounted && generation == _generation) {
        state = state.copyWith(
            error:
                'Nhận diện âm thanh đang gián đoạn. Kiểm tra backend và kết nối mạng.');
      }
    } finally {
      _analyzing = false;
    }
  }

  Map<String, dynamic> _context(AudioAnalysisInput input) => {
        'monitoring_session_id': _streamId,
        'captured_at': input.capturedAt.toUtc().toIso8601String(),
        if (_safetyCheckId != null) 'safety_check_instance_id': _safetyCheckId,
        'latitude': _latitude,
        'longitude': _longitude,
      };

  Future<ServerAudioAlert?> _analyzeOnServer(AudioAnalysisInput input) async {
    final response = await _api.post<dynamic>('/detection/analyze-audio',
        data: {
          ..._context(input),
          'window_end_sample': input.endSample,
          'audio_base64':
              base64Encode(AudioRecorderService.encodeToWav(input.pcm)),
          'sample_rate': 16000,
          'decibel_peak': input.peakDbfs,
        },
        options: Options(receiveTimeout: const Duration(seconds: 8)));
    final data = _unwrap(response.data);
    return data is Map && data['alert'] is Map
        ? ServerAudioAlert.fromJson(data['alert'] as Map)
        : null;
  }

  Future<void> _accept(ServerAudioAlert alert) async {
    if (!mounted) return;
    final revision = ++_alertRevision;
    final generation = _alertGeneration;
    if (alert.status == 'PENDING' || alert.status == 'DISPATCHING') {
      _ref.read(dangerAlertProvider.notifier).synchronizeServerAlert(alert,
          onConfirm: () => _decide(alert.id, 'confirm'),
          onCancel: () => _decide(alert.id, 'cancel'));
    } else if (alert.status == 'CANCELLED') {
      _ref
          .read(dangerAlertProvider.notifier)
          .resolveServerAlert(alert.id, sent: false);
    } else if (alert.status == 'SOS_CREATED' && alert.sessionId != null) {
      state = state.copyWith(
          error: state.error,
          deliveryStatus: alert.deliveryStatus,
          recipientsTotal: alert.total,
          recipientsSent: alert.sent,
          recipientsFailed: alert.failed);
      final response =
          await _api.get<dynamic>('/emergency/sessions/${alert.sessionId}');
      if (!mounted ||
          generation != _alertGeneration ||
          revision != _alertRevision) {
        return;
      }
      final session = EmergencySessionModel.fromJson(
              Map<String, dynamic>.from(_unwrap(response.data) as Map))
          .toEntity();
      _ref.read(sosControllerProvider.notifier).restoreServerSession(session);
      _ref
          .read(dangerAlertProvider.notifier)
          .resolveServerAlert(alert.id, sent: true);
    }
  }

  Future<void> _decide(String id, String action) async {
    final generation = _alertGeneration;
    final response = await _api.post<dynamic>('/detection/alerts/$id/$action');
    if (!mounted || generation != _alertGeneration) return;
    final alert = ServerAudioAlert.fromJson(_unwrap(response.data) as Map);
    await _accept(alert);
    if (action == 'cancel' && alert.status != 'CANCELLED') {
      throw StateError('SOS đã đến hạn gửi. Cảnh báo chưa được hủy.');
    }
  }

  Future<void> stopMonitoring() async {
    _generation++;
    _analysisTimer?.cancel();
    _recorder.onAudioChunk = null;
    _queue.clear();
    _safetyCheckId = null;
    state = state.copyWith(isMonitoring: false, isEnabled: false);
    await _recorder.stop();
    // Stopping a microphone is not cancellation of an accepted server alert.
  }

  Future<void> endLocalSession() async {
    _alertGeneration++;
    _alertRealtime?.stop();
    _alertRealtime = null;
    await stopMonitoring();
    _latitude = null;
    _longitude = null;
    _ref.read(dangerAlertProvider.notifier).resetSession();
    state = const DangerAudioState();
  }

  Future<void> toggleMonitoring() async {
    if (state.isMonitoring) {
      await stopMonitoring();
    } else {
      await startMonitoring();
    }
  }

  Future<void> flushUploadQueue(
      {Duration timeout = const Duration(seconds: 3)}) async {}
  void clearHistory() {
    state = state.copyWith(detectionHistory: []);
  }

  void clearError() {
    state = state.copyWith();
  }

  @override
  void dispose() {
    _generation++;
    _alertGeneration++;
    WidgetsBinding.instance.removeObserver(this);
    _analysisTimer?.cancel();
    _alertRealtime?.stop();
    _recorder.onAudioChunk = null;
    _queue.clear();
    unawaited(_recorder.dispose());
    super.dispose();
  }
}

final dangerAudioProvider =
    StateNotifierProvider<DangerAudioNotifier, DangerAudioState>(
        (ref) => DangerAudioNotifier(ref));
final isMonitoringProvider =
    Provider<bool>((ref) => ref.watch(dangerAudioProvider).isMonitoring);
final lastDetectionProvider = Provider<DangerDetectionResult?>(
    (ref) => ref.watch(dangerAudioProvider).lastDetection);
final detectionHistoryProvider = Provider<List<DangerDetectionResult>>(
    (ref) => ref.watch(dangerAudioProvider).detectionHistory);
final pendingUploadsProvider = Provider<int>((ref) => 0);
final hasPermissionProvider =
    Provider<bool>((ref) => ref.watch(dangerAudioProvider).hasPermission);
