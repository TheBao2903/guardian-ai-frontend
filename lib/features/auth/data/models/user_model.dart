/// ============================================================================
/// FILE: lib/features/auth/data/models/user_model.dart
/// MODULE: Auth - Data Models
/// ROLE:
///   DTO mapping cho AuthenticatedUser và UserProfileResponse từ backend.
/// ============================================================================

import '../../domain/entities/user_entity.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone,
    this.telegramId,
    this.bloodType = 'O+',
    this.allergies = 'Penicillin, Aspirin',
    this.medicalNotes = 'Hen suyễn nhẹ',
    this.sosPin = '1234',
    this.deviceInfo,
    this.locationPermissionGranted = false,
    this.lastKnownLocation,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? phone;
  final String? telegramId;
  final String bloodType;
  final String allergies;
  final String medicalNotes;
  final String sosPin;
  final Map<String, dynamic>? deviceInfo;
  final bool locationPermissionGranted;
  final Map<String, dynamic>? lastKnownLocation;

  String? get telegramUsername => telegramId;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['name'] as String? ?? json['display_name'] as String? ?? 'Người dùng',
      phone: json['phone'] as String?,
      telegramId: json['telegram_id'] as String? ?? json['telegram_username'] as String?,
      bloodType: json['blood_type'] as String? ?? 'O+',
      allergies: json['allergies'] is List
          ? (json['allergies'] as List).join(', ')
          : (json['allergies'] as String? ?? 'Không có dị ứng ghi nhận'),
      medicalNotes: json['medical_notes'] as String? ?? 'Sức khỏe bình thường',
      sosPin: json['sos_pin'] as String? ?? '1234',
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      locationPermissionGranted: json['location_permission_granted'] as bool? ?? false,
      lastKnownLocation: json['last_known_location'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': displayName,
      'phone': phone,
      'telegram_id': telegramId,
      'blood_type': bloodType,
      'allergies': allergies,
      'medical_notes': medicalNotes,
      'sos_pin': sosPin,
      'device_info': deviceInfo,
      'location_permission_granted': locationPermissionGranted,
      'last_known_location': lastKnownLocation,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      phone: phone,
      telegramId: telegramId,
      bloodType: bloodType,
      allergies: allergies,
      medicalNotes: medicalNotes,
      sosPin: sosPin,
      deviceInfo: deviceInfo,
      locationPermissionGranted: locationPermissionGranted,
      lastKnownLocation: lastKnownLocation,
    );
  }
}
