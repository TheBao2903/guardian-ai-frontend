/// ============================================================================
/// FILE: lib/features/safety_check/domain/usecases/confirm_safe_usecase.dart
/// MODULE: Safety Check - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/safety_check_entity.dart';
import '../repositories/safety_check_repository.dart';

class ConfirmSafeUseCase {
  const ConfirmSafeUseCase(this._repository);

  final SafetyCheckRepository _repository;

  Future<Result<SafetyCheckEntity>> call({
    required String instanceId,
    String? pinCode,
    String? note,
  }) {
    return _repository.confirmSafe(
      instanceId: instanceId,
      pinCode: pinCode,
      note: note,
    );
  }
}
