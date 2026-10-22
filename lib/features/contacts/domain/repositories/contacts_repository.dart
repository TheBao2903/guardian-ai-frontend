/// ============================================================================
/// FILE: lib/features/contacts/domain/repositories/contacts_repository.dart
/// MODULE: Contacts - Domain Repository Interface
/// ROLE:
///   Quy định hợp đồng kết nối dữ liệu danh bạ khẩn cấp (Guardian Circle).
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/contact_entity.dart';

abstract class ContactsRepository {
  /// Lấy danh sách tối đa 10 người thân khẩn cấp (sắp xếp theo priority)
  Future<Result<List<ContactEntity>>> getContacts();

  /// Thêm người thân mới
  Future<Result<ContactEntity>> addContact({
    required String name,
    required ContactRelationshipEnum relationship,
    required String phone,
    String? telegramId,
    int? priority,
  });

  /// Cập nhật thông tin người thân
  Future<Result<ContactEntity>> updateContact({
    required String id,
    String? name,
    ContactRelationshipEnum? relationship,
    String? phone,
    String? telegramId,
    int? priority,
    bool? isActive,
  });

  /// Xóa người thân khỏi danh bạ
  Future<Result<void>> deleteContact(String id);

  /// Sắp xếp lại thứ tự ưu tiên
  Future<Result<List<ContactEntity>>> reorderContacts(
    List<Map<String, dynamic>> orders,
  );
}
