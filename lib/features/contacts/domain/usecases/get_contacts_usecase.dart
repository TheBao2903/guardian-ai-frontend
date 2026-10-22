/// ============================================================================
/// FILE: lib/features/contacts/domain/usecases/get_contacts_usecase.dart
/// MODULE: Contacts - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/contact_entity.dart';
import '../repositories/contacts_repository.dart';

class GetContactsUseCase {
  const GetContactsUseCase(this._repository);

  final ContactsRepository _repository;

  Future<Result<List<ContactEntity>>> call() {
    return _repository.getContacts();
  }
}
