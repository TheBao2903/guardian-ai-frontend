/// ============================================================================
/// FILE: lib/features/safety_check/domain/usecases/get_safety_check_templates_usecase.dart
/// MODULE: Safety Check - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/safety_check_template_entity.dart';
import '../repositories/safety_check_repository.dart';

class GetSafetyCheckTemplatesUseCase {
  const GetSafetyCheckTemplatesUseCase(this._repository);

  final SafetyCheckRepository _repository;

  Future<Result<List<SafetyCheckTemplateEntity>>> call() {
    return _repository.getTemplates();
  }
}
