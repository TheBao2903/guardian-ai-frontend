/// ============================================================================
/// FILE: lib/features/sos/domain/usecases/cancel_sos_usecase.dart
/// MODULE: Emergency & SOS - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/emergency_session_entity.dart';
import '../repositories/emergency_repository.dart';

class CancelSosUseCase {
  const CancelSosUseCase(this._repository);

  final EmergencyRepository _repository;

  Future<Result<EmergencySessionEntity>> call({
    required String pinCode,
    String? reason,
  }) {
    return _repository.cancelSos(
      pinCode: pinCode,
      reason: reason,
    );
  }
}
