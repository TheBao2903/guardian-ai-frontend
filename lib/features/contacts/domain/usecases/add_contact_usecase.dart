/// ============================================================================
/// FILE: lib/features/contacts/domain/usecases/add_contact_usecase.dart
/// MODULE: Contacts - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/contact_entity.dart';
import '../repositories/contacts_repository.dart';

class AddContactUseCase {
  const AddContactUseCase(this._repository);

  final ContactsRepository _repository;

  Future<Result<ContactEntity>> call({
    required String name,
    required ContactRelationshipEnum relationship,
    required String phone,
    String? telegramId,
    int? priority,
  }) {
    return _repository.addContact(
      name: name,
      relationship: relationship,
      phone: phone,
      telegramId: telegramId,
      priority: priority,
    );
  }
}
