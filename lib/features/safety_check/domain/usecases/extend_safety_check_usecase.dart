/// ============================================================================
/// FILE: lib/features/safety_check/domain/usecases/extend_safety_check_usecase.dart
/// MODULE: Safety Check - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/safety_check_entity.dart';
import '../repositories/safety_check_repository.dart';

class ExtendSafetyCheckUseCase {
  const ExtendSafetyCheckUseCase(this._repository);

  final SafetyCheckRepository _repository;

  Future<Result<SafetyCheckEntity>> call({
    required String instanceId,
    int extendMinutes = 15,
  }) {
    return _repository.extendSafetyCheck(
      instanceId: instanceId,
      extendMinutes: extendMinutes,
    );
  }
}
