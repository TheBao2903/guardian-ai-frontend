/// ============================================================================
/// FILE: lib/features/safety_check/data/repositories/safety_check_repository_impl.dart
/// MODULE: Safety Check - Data Repository Implementation
/// ROLE:
///   Triển khai SafetyCheckRepository, xử lý mapping DTO -> Domain Entity
///   và chuyển đổi toàn bộ ngoại lệ thành Functional Result<T>.
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/safety_check_entity.dart';
import '../../domain/entities/safety_check_template_entity.dart';
import '../../domain/repositories/safety_check_repository.dart';
import '../datasources/safety_check_remote_data_source.dart';

final safetyCheckRepositoryProvider = Provider<SafetyCheckRepository>((ref) {
  final dataSource = ref.watch(safetyCheckRemoteDataSourceProvider);
  return SafetyCheckRepositoryImpl(dataSource);
});

class SafetyCheckRepositoryImpl implements SafetyCheckRepository {
  const SafetyCheckRepositoryImpl(this._remoteDataSource);

  final SafetyCheckRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<SafetyCheckTemplateEntity>>> getTemplates() async {
    try {
      final models = await _remoteDataSource.getTemplates();
      final entities = models.map((m) => m.toEntity()).toList();
      return Result.success(entities);
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<SafetyCheckTemplateEntity>> saveTemplate(
      Map<String, dynamic> data,
      {String? templateId}) async {
    try {
      final model =
          await _remoteDataSource.saveTemplate(data, templateId: templateId);
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTemplate(String templateId) async {
    try {
      await _remoteDataSource.deleteTemplate(templateId);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<SafetyCheckEntity?>> getCurrentSafetyCheck() async {
    try {
      final model = await _remoteDataSource.getCurrentSafetyCheck();
      return Result.success(model?.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<SafetyCheckEntity>> startSafetyCheck({
    String? templateId,
    String? customName,
    required int durationMinutes,
    int? gracePeriodSeconds,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      final model = await _remoteDataSource.startSafetyCheck(
        templateId: templateId,
        customName: customName,
        durationMinutes: durationMinutes,
        gracePeriodSeconds: gracePeriodSeconds,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(
          ServerFailure('Không thể bắt đầu Safety Check. Vui lòng thử lại.'));
    }
  }

  @override
  Future<Result<SafetyCheckEntity>> confirmSafe({
    required String instanceId,
    String? pinCode,
    String? note,
  }) async {
    try {
      final model = await _remoteDataSource.confirmSafe(
        instanceId: instanceId,
        pinCode: pinCode,
        note: note,
      );
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(
          ServerFailure('Không thể xác nhận an toàn. Vui lòng thử lại.'));
    }
  }

  @override
  Future<Result<SafetyCheckEntity>> extendSafetyCheck({
    required String instanceId,
    int extendMinutes = 15,
  }) async {
    try {
      final model = await _remoteDataSource.extendSafetyCheck(
        instanceId: instanceId,
        extendMinutes: extendMinutes,
      );
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> cancelSafetyCheck({
    required String instanceId,
    String? reason,
  }) async {
    try {
      await _remoteDataSource.cancelSafetyCheck(
        instanceId: instanceId,
        reason: reason,
      );
      return Result.success(null);
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.success(null);
    }
  }

  @override
  Future<Result<void>> updateLocation({
    required String instanceId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
  }) async {
    try {
      await _remoteDataSource.updateLocation(
        instanceId: instanceId,
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
      );
      return Result.success(null);
    } catch (e) {
      return Result.error(NetworkFailure(e.toString()));
    }
  }
}
