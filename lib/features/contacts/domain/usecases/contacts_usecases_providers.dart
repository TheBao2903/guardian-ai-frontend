/// ============================================================================
/// FILE: lib/features/contacts/domain/usecases/contacts_usecases_providers.dart
/// MODULE: Contacts - Domain Providers
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/contacts_repository_impl.dart';
import 'add_contact_usecase.dart';
import 'delete_contact_usecase.dart';
import 'get_contacts_usecase.dart';

final getContactsUseCaseProvider = Provider<GetContactsUseCase>((ref) {
  final repo = ref.watch(contactsRepositoryProvider);
  return GetContactsUseCase(repo);
});

final addContactUseCaseProvider = Provider<AddContactUseCase>((ref) {
  final repo = ref.watch(contactsRepositoryProvider);
  return AddContactUseCase(repo);
});

final deleteContactUseCaseProvider = Provider<DeleteContactUseCase>((ref) {
  final repo = ref.watch(contactsRepositoryProvider);
  return DeleteContactUseCase(repo);
});
