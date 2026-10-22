/// ============================================================================
/// FILE: lib/features/sos/data/repositories/emergency_repository_impl.dart
/// MODULE: Emergency & SOS - Data Repository Implementation
/// ROLE:
///   Triển khai EmergencyRepository với cơ chế chịu lỗi ngoại lệ mạng.
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/emergency_session_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_remote_data_source.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final dataSource = ref.watch(emergencyRemoteDataSourceProvider);
  return EmergencyRepositoryImpl(dataSource);
});

class EmergencyRepositoryImpl implements EmergencyRepository {
  const EmergencyRepositoryImpl(this._remoteDataSource);

  final EmergencyRemoteDataSource _remoteDataSource;

  @override
  Future<Result<EmergencySessionEntity>> triggerSos({
    String triggerType = 'MANUAL_SOS',
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? notes,
    String? recordingId,
  }) async {
    try {
      final model = await _remoteDataSource.triggerSos(
        triggerType: triggerType,
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
        notes: notes,
        recordingId: recordingId,
      );
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure('Không thể kích hoạt SOS. Vui lòng thử lại.'));
    }
  }

  @override
  Future<Result<EmergencySessionEntity>> cancelSos({
    required String pinCode,
    String? reason,
  }) async {
    try {
      final model = await _remoteDataSource.cancelSos(
        pinCode: pinCode,
        reason: reason,
      );
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure('Không thể hủy SOS. Vui lòng thử lại.'));
    }
  }

  @override
  Future<Result<EmergencySessionEntity?>> getActiveSosSession() async {
    try {
      final model = await _remoteDataSource.getActiveSosSession();
      return Result.success(model?.toEntity());
    } catch (e) {
      return Result.success(null);
    }
  }
}
