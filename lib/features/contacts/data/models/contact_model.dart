/// ============================================================================
/// FILE: lib/features/contacts/data/models/contact_model.dart
/// MODULE: Contacts - Data Models
/// ROLE:
///   DTO Serialization và Deserialization cho ContactResponse.
/// ============================================================================

import '../../domain/entities/contact_entity.dart';

class ContactModel {
  const ContactModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    required this.phone,
    this.telegramId,
    required this.priority,
    this.isActive = true,
  });

  final String id;
  final String userId;
  final String name;
  final String relationship;
  final String phone;
  final String? telegramId;
  final int priority;
  final bool isActive;

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String,
      relationship: json['relationship'] as String? ?? 'OTHER',
      phone: json['phone'] as String,
      telegramId: json['telegram_id'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'telegram_id': telegramId,
      'priority': priority,
      'is_active': isActive,
    };
  }

  ContactEntity toEntity() {
    ContactRelationshipEnum rel;
    switch (relationship.toUpperCase()) {
      case 'PARENT':
        rel = ContactRelationshipEnum.parent;
        break;
      case 'SPOUSE':
        rel = ContactRelationshipEnum.spouse;
        break;
      case 'SIBLING':
        rel = ContactRelationshipEnum.sibling;
        break;
      case 'CHILD':
        rel = ContactRelationshipEnum.child;
        break;
      case 'FRIEND':
        rel = ContactRelationshipEnum.friend;
        break;
      case 'COLLEAGUE':
        rel = ContactRelationshipEnum.colleague;
        break;
      default:
        rel = ContactRelationshipEnum.other;
    }

    return ContactEntity(
      id: id,
      name: name,
      relationship: rel,
      phone: phone,
      telegramId: telegramId,
      priority: priority,
      isActive: isActive,
    );
  }

  static String relationshipToDto(ContactRelationshipEnum rel) {
    switch (rel) {
      case ContactRelationshipEnum.parent:
        return 'PARENT';
      case ContactRelationshipEnum.spouse:
        return 'SPOUSE';
      case ContactRelationshipEnum.sibling:
        return 'SIBLING';
      case ContactRelationshipEnum.child:
        return 'CHILD';
      case ContactRelationshipEnum.friend:
        return 'FRIEND';
      case ContactRelationshipEnum.colleague:
        return 'COLLEAGUE';
      case ContactRelationshipEnum.other:
        return 'OTHER';
    }
  }
}
