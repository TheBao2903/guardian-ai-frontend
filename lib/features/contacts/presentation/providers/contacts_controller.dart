/// ============================================================================
/// FILE: lib/features/contacts/presentation/providers/contacts_controller.dart
/// MODULE: Contacts - Presentation Controller
/// ROLE:
///   StateNotifier điều phối danh bạ khẩn cấp: Tải danh sách, thêm người thân,
///   xóa và đặt người ưu tiên gọi #1.
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/contact_entity.dart';
import '../../data/repositories/contacts_repository_impl.dart';
import '../../domain/usecases/contacts_usecases_providers.dart';
import 'contacts_state.dart';

final contactsControllerProvider =
    StateNotifierProvider<ContactsController, ContactsState>((ref) {
  return ContactsController(ref);
});

class ContactsController extends StateNotifier<ContactsState> {
  ContactsController(this._ref) : super(const ContactsState()) {
    loadContacts();
  }

  final Ref _ref;

  /// Tải danh bạ khẩn cấp
  Future<void> loadContacts() async {
    final token =
        await _ref.read(secureStorageProvider).read(StorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final getContactsUseCase = _ref.read(getContactsUseCaseProvider);
    final result = await getContactsUseCase();

    result.when(
      success: (data) {
        state = state.copyWith(
          isLoading: false,
          contacts: data,
        );
      },
      error: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Thêm người thân mới
  ///
  /// [isPrimary] - Nếu true, đặt người mới làm ưu tiên gọi #1
  /// và tự động hạ priority của người cũ xuống
  Future<bool> addContact({
    required String name,
    required ContactRelationshipEnum relationship,
    required String phone,
    String? telegramId,
    bool isPrimary = false,
  }) async {
    if (!state.canAddMore) {
      state =
          state.copyWith(errorMessage: 'Đã đạt giới hạn tối đa 10 người thân.');
      return false;
    }

    state = state.copyWith(isActionLoading: true);
    final addUseCase = _ref.read(addContactUseCaseProvider);
    final nextPriority = state.contacts.length + 1;

    // Nếu là primary mới, tạo với priority = 1
    // Backend sẽ tự xử lý hoán đổi với contact cũ
    final priorityToUse = isPrimary ? 1 : nextPriority;

    final result = await addUseCase(
      name: name,
      relationship: relationship,
      phone: phone,
      telegramId: telegramId,
      priority: priorityToUse,
    );

    return result.when(
      success: (newContact) async {
        if (isPrimary) {
          // Đưa người mới lên đầu với priority = 1, hạ các liên hệ cũ xuống 2, 3, 4...
          final otherContacts = state.contacts
              .where((c) => c.id != newContact.id)
              .toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));
          final updatedOthers = <ContactEntity>[];
          for (int i = 0; i < otherContacts.length; i++) {
            updatedOthers.add(otherContacts[i].copyWith(priority: i + 2));
          }
          final newPrimary = newContact.copyWith(priority: 1);
          state = state.copyWith(
            isActionLoading: false,
            contacts: [newPrimary, ...updatedOthers],
          );
          await loadContacts();
          return true;
        }

        final updatedList = [...state.contacts, newContact]
          ..sort((a, b) => a.priority.compareTo(b.priority));
        state = state.copyWith(
          isActionLoading: false,
          contacts: updatedList,
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Chỉ thay dữ liệu sau khi máy chủ xác nhận cập nhật thành công.
  Future<bool> updateContact({
    required String id,
    required String name,
    required ContactRelationshipEnum relationship,
    required String phone,
    required String telegramId,
  }) async {
    if (state.isActionLoading) return false;
    state = state.copyWith(isActionLoading: true);
    final result = await _ref.read(contactsRepositoryProvider).updateContact(
          id: id,
          name: name,
          relationship: relationship,
          phone: phone,
          telegramId: telegramId,
        );
    if (!mounted) return false;
    return result.when(
      success: (updated) {
        state = state.copyWith(
          isActionLoading: false,
          contacts: state.contacts
              .map((contact) => contact.id == id ? updated : contact)
              .toList(),
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Đặt một người thân làm ưu tiên gọi #1
  ///
  /// Cập nhật tức thì (Optimistic UI):
  /// - Đánh dấu người này là #1 (isPrimaryCaller = true, sao vàng)
  /// - Đẩy người này lên vị trí đầu tiên của danh sách
  /// - Tự động hạ thứ tự ưu tiên của các người thân khác xuống 2, 3, 4...
  Future<bool> setPrimaryContact(String contactId) async {
    final targetIndex = state.contacts.indexWhere((c) => c.id == contactId);
    if (targetIndex == -1) return false;

    final target = state.contacts[targetIndex];
    if (target.isPrimaryCaller) {
      return true; // Đã là ưu tiên #1 rồi
    }

    // 1. Optimistic UI update ngay lập tức:
    // Đặt target có priority = 1, các contact khác tăng priority lên 2, 3, 4...
    final otherContacts = state.contacts
        .where((c) => c.id != contactId)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    final updatedTarget = target.copyWith(priority: 1);
    final updatedOthers = <ContactEntity>[];
    for (int i = 0; i < otherContacts.length; i++) {
      updatedOthers.add(otherContacts[i].copyWith(priority: i + 2));
    }

    final newContacts = [updatedTarget, ...updatedOthers];

    // Cập nhật State ngay lập tức để UI đẩy lên đầu và đổi icon sao vàng
    state = state.copyWith(
      contacts: newContacts,
      isActionLoading: false,
    );

    // 2. Gửi request lên Backend FastAPI để lưu Firestore
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.post<dynamic>('/contacts/$contactId/set-primary');

      // Tải lại để đảm bảo dữ liệu đồng bộ hoàn toàn với server
      await loadContacts();
      return true;
    } catch (e) {
      // Dù API gặp sự cố mạng tạm thời, local state đã được cập nhật
      state = state.copyWith(
        errorMessage: 'Lưu ưu tiên trên máy chủ gặp sự cố: ${e.toString()}',
      );
      return true;
    }
  }

  /// Xóa người thân
  Future<bool> deleteContact(String id) async {
    state = state.copyWith(isActionLoading: true);
    final deleteUseCase = _ref.read(deleteContactUseCaseProvider);
    final result = await deleteUseCase(id);

    return result.when(
      success: (_) {
        final updated = state.contacts.where((c) => c.id != id).toList();
        state = state.copyWith(
          isActionLoading: false,
          contacts: updated,
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }
}
