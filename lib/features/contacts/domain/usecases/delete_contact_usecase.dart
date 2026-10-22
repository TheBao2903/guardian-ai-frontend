/// ============================================================================
/// FILE: lib/features/contacts/domain/usecases/delete_contact_usecase.dart
/// MODULE: Contacts - Domain Use Cases
/// ============================================================================

import '../../../../core/error/result.dart';
import '../repositories/contacts_repository.dart';

class DeleteContactUseCase {
  const DeleteContactUseCase(this._repository);

  final ContactsRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteContact(id);
  }
}
