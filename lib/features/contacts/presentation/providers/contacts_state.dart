/// ============================================================================
/// FILE: lib/features/contacts/presentation/providers/contacts_state.dart
/// MODULE: Contacts - Presentation State
/// ROLE:
///   Quản lý danh bạ Guardian Circle (Tối đa 10 người thân Telegram).
/// ============================================================================

import '../../domain/entities/contact_entity.dart';

class ContactsState {
  const ContactsState({
    this.isLoading = false,
    this.errorMessage,
    this.contacts = const [],
    this.isActionLoading = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<ContactEntity> contacts;
  final bool isActionLoading;

  ContactEntity? get primaryContact {
    if (contacts.isEmpty) return null;
    return sortedContacts.first;
  }

  /// Danh sách người thân đã được sắp xếp theo mức độ ưu tiên tăng dần (#1 lên đầu)
  List<ContactEntity> get sortedContacts {
    final sorted = List<ContactEntity>.from(contacts)
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return sorted;
  }

  int get remainingSlots => 10 - contacts.length;
  bool get canAddMore => contacts.length < 10;

  /// Lấy tổng cộng 5 người thân ưu tiên (Priority 1-5) cho SOS screen
  List<ContactEntity> get priorityContactsForSos {
    if (contacts.isEmpty) return [];
    final sorted = List<ContactEntity>.from(contacts)
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return sorted.take(5).toList();
  }

  /// Lấy 3 người thân nhận audio evidence (Priority 1-3)
  List<ContactEntity> get audioRecipients {
    if (contacts.isEmpty) return [];
    final sorted = List<ContactEntity>.from(contacts)
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return sorted.take(3).toList();
  }

  /// Lấy tất cả người thân nhận notification (tất cả active contacts có Telegram)
  List<ContactEntity> get notificationRecipients {
    return contacts.where((c) => c.isActive && c.hasTelegramConnected).toList();
  }

  ContactsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ContactEntity>? contacts,
    bool? isActionLoading,
  }) {
    return ContactsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      contacts: contacts ?? this.contacts,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }
}
