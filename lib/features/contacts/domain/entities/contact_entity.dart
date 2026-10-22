/// ============================================================================
/// FILE: lib/features/contacts/domain/entities/contact_entity.dart
/// MODULE: Contacts - Domain Entities
/// ROLE:
///   Thực thể Người thân khẩn cấp (Guardian Circle - Tối đa 10 người).
/// ============================================================================

enum ContactRelationshipEnum {
  parent,
  spouse,
  sibling,
  child,
  friend,
  colleague,
  other,
}

class ContactEntity {
  const ContactEntity({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.telegramId,
    required this.priority,
    this.isActive = true,
  });

  final String id;
  final String name;
  final ContactRelationshipEnum relationship;
  final String phone;
  final String? telegramId;
  final int priority;
  final bool isActive;

  bool get isPrimaryCaller => priority == 1;
  bool get hasTelegramConnected => telegramId != null && telegramId!.isNotEmpty;

  String get relationshipDisplay {
    switch (relationship) {
      case ContactRelationshipEnum.parent:
        return 'Bố / Mẹ';
      case ContactRelationshipEnum.spouse:
        return 'Vợ / Chồng';
      case ContactRelationshipEnum.sibling:
        return 'Anh / Chị / Em';
      case ContactRelationshipEnum.child:
        return 'Con';
      case ContactRelationshipEnum.friend:
        return 'Bạn thân';
      case ContactRelationshipEnum.colleague:
        return 'Đồng nghiệp';
      case ContactRelationshipEnum.other:
        return 'Người quen';
    }
  }

  ContactEntity copyWith({
    String? id,
    String? name,
    ContactRelationshipEnum? relationship,
    String? phone,
    String? telegramId,
    int? priority,
    bool? isActive,
  }) {
    return ContactEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      telegramId: telegramId ?? this.telegramId,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
    );
  }
}
