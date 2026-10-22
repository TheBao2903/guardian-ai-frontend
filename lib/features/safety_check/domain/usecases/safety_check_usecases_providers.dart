/// ============================================================================
/// FILE: lib/features/safety_check/domain/usecases/safety_check_usecases_providers.dart
/// MODULE: Safety Check - Domain Providers
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/safety_check_repository_impl.dart';
import 'cancel_safety_check_usecase.dart';
import 'confirm_safe_usecase.dart';
import 'extend_safety_check_usecase.dart';
import 'get_current_safety_check_usecase.dart';
import 'get_safety_check_templates_usecase.dart';
import 'start_safety_check_usecase.dart';

final getSafetyCheckTemplatesUseCaseProvider =
    Provider<GetSafetyCheckTemplatesUseCase>((ref) {
  final repo = ref.watch(safetyCheckRepositoryProvider);
  return GetSafetyCheckTemplatesUseCase(repo);
});

final getCurrentSafetyCheckUseCaseProvider =
    Provider<GetCurrentSafetyCheckUseCase>((ref) {
  final repo = ref.watch(safetyCheckRepositoryProvider);
  return GetCurrentSafetyCheckUseCase(repo);
});

final startSafetyCheckUseCaseProvider =
    Provider<StartSafetyCheckUseCase>((ref) {
  final repo = ref.watch(safetyCheckRepositoryProvider);
  return StartSafetyCheckUseCase(repo);
});

final confirmSafeUseCaseProvider = Provider<ConfirmSafeUseCase>((ref) {
  final repo = ref.watch(safetyCheckRepositoryProvider);
  return ConfirmSafeUseCase(repo);
});

final extendSafetyCheckUseCaseProvider =
    Provider<ExtendSafetyCheckUseCase>((ref) {
  final repo = ref.watch(safetyCheckRepositoryProvider);
  return ExtendSafetyCheckUseCase(repo);
});

final cancelSafetyCheckUseCaseProvider =
    Provider<CancelSafetyCheckUseCase>((ref) {
  final repo = ref.watch(safetyCheckRepositoryProvider);
  return CancelSafetyCheckUseCase(repo);
});
