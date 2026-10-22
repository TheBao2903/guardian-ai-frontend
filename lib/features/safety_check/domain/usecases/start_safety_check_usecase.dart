/// ============================================================================
/// FILE: lib/features/safety_check/domain/usecases/start_safety_check_usecase.dart
/// MODULE: Safety Check - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/safety_check_entity.dart';
import '../repositories/safety_check_repository.dart';

class StartSafetyCheckUseCase {
  const StartSafetyCheckUseCase(this._repository);

  final SafetyCheckRepository _repository;

  Future<Result<SafetyCheckEntity>> call({
    String? templateId,
    String? customName,
    required int durationMinutes,
    int? gracePeriodSeconds,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return _repository.startSafetyCheck(
      templateId: templateId,
      customName: customName,
      durationMinutes: durationMinutes,
      gracePeriodSeconds: gracePeriodSeconds,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
    );
  }
}
