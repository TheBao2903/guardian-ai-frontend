/// ============================================================================
/// FILE: lib/features/sos/domain/usecases/trigger_sos_usecase.dart
/// MODULE: Emergency & SOS - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/emergency_session_entity.dart';
import '../repositories/emergency_repository.dart';

class TriggerSosUseCase {
  const TriggerSosUseCase(this._repository);

  final EmergencyRepository _repository;

  Future<Result<EmergencySessionEntity>> call({
    String triggerType = 'MANUAL_SOS',
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? notes,
    String? recordingId,
  }) {
    return _repository.triggerSos(
      triggerType: triggerType,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      notes: notes,
      recordingId: recordingId,
    );
  }
}
