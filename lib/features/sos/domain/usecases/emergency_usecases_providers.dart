/// ============================================================================
/// FILE: lib/features/sos/domain/usecases/emergency_usecases_providers.dart
/// MODULE: Emergency & SOS - Domain Providers
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/emergency_repository_impl.dart';
import 'cancel_sos_usecase.dart';
import 'get_active_sos_usecase.dart';
import 'trigger_sos_usecase.dart';

final triggerSosUseCaseProvider = Provider<TriggerSosUseCase>((ref) {
  final repo = ref.watch(emergencyRepositoryProvider);
  return TriggerSosUseCase(repo);
});

final cancelSosUseCaseProvider = Provider<CancelSosUseCase>((ref) {
  final repo = ref.watch(emergencyRepositoryProvider);
  return CancelSosUseCase(repo);
});

final getActiveSosUseCaseProvider = Provider<GetActiveSosUseCase>((ref) {
  final repo = ref.watch(emergencyRepositoryProvider);
  return GetActiveSosUseCase(repo);
});
