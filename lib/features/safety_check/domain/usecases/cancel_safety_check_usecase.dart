/// ============================================================================
/// FILE: lib/features/safety_check/domain/usecases/cancel_safety_check_usecase.dart
/// MODULE: Safety Check - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../repositories/safety_check_repository.dart';

class CancelSafetyCheckUseCase {
  const CancelSafetyCheckUseCase(this._repository);

  final SafetyCheckRepository _repository;

  Future<Result<void>> call({
    required String instanceId,
    String? reason,
  }) {
    return _repository.cancelSafetyCheck(
      instanceId: instanceId,
      reason: reason,
    );
  }
}
