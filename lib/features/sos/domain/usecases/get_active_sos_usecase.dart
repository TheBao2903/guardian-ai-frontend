/// ============================================================================
/// FILE: lib/features/sos/domain/usecases/get_active_sos_usecase.dart
/// MODULE: Emergency & SOS - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/emergency_session_entity.dart';
import '../repositories/emergency_repository.dart';

class GetActiveSosUseCase {
  const GetActiveSosUseCase(this._repository);

  final EmergencyRepository _repository;

  Future<Result<EmergencySessionEntity?>> call() {
    return _repository.getActiveSosSession();
  }
}
