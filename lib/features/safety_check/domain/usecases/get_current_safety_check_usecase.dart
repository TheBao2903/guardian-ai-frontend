/// ============================================================================
/// FILE: lib/features/safety_check/domain/usecases/get_current_safety_check_usecase.dart
/// MODULE: Safety Check - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/safety_check_entity.dart';
import '../repositories/safety_check_repository.dart';

class GetCurrentSafetyCheckUseCase {
  const GetCurrentSafetyCheckUseCase(this._repository);

  final SafetyCheckRepository _repository;

  Future<Result<SafetyCheckEntity?>> call() {
    return _repository.getCurrentSafetyCheck();
  }
}
