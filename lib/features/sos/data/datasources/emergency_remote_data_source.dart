/// ============================================================================
/// FILE: lib/features/sos/data/datasources/emergency_remote_data_source.dart
/// MODULE: Emergency & SOS - Remote Data Source
/// ROLE:
///   Giao tiếp trực tiếp với FastAPI backend phục vụ kích hoạt & hủy SOS.
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/emergency_session_model.dart';

final emergencyRemoteDataSourceProvider = Provider<EmergencyRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EmergencyRemoteDataSource(apiClient);
});

class EmergencyRemoteDataSource {
  const EmergencyRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Kích hoạt phiên khẩn cấp SOS
  Future<EmergencySessionModel> triggerSos({
    String triggerType = 'MANUAL_SOS',
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? notes,
    String? recordingId,
  }) async {
    final payload = <String, dynamic>{
      'trigger_type': triggerType,
      'severity': 'CRITICAL',
    };
    if (latitude != null) payload['latitude'] = latitude;
    if (longitude != null) payload['longitude'] = longitude;
    if (accuracyMeters != null) payload['accuracy_meters'] = accuracyMeters;
    if (notes != null) payload['notes'] = notes;
    if (recordingId != null) payload['recording_id'] = recordingId;

    final response = await _apiClient.post(
      ApiConstants.emergencySos,
      data: payload,
    );
    final data = response.data as Map<String, dynamic>;
    return EmergencySessionModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Hủy phiên khẩn cấp SOS bằng mã PIN an toàn
  Future<EmergencySessionModel> cancelSos({
    required String pinCode,
    String? reason,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.emergencyCancel,
      data: {
        'pin_code': pinCode,
        'cancelled_reason': reason ?? 'Người dùng chủ động hủy bằng mã PIN an toàn.',
      },
    );
    final data = response.data as Map<String, dynamic>;
    return EmergencySessionModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Lấy trạng thái phiên SOS
  Future<EmergencySessionModel?> getActiveSosSession() async {
    final response = await _apiClient.get(ApiConstants.emergencyStatus);
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return EmergencySessionModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return null;
  }
}
