/// ============================================================================
/// FILE: lib/features/auth/domain/entities/user_entity.dart
/// MODULE: Auth - Domain User Entity
/// ROLE:
///   Đại diện cho thông tin tài khoản người dùng đăng nhập hệ thống.
/// ============================================================================

class UserEntity {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone,
    this.telegramId,
    this.bloodType = '',
    this.allergies = '',
    this.medicalNotes = '',
    this.sosPin = '1234',
    this.deviceInfo,
    this.locationPermissionGranted = false,
    this.lastKnownLocation,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? phone;
  final String? telegramId; // Dãy số Chat ID Telegram của cá nhân
  final String bloodType;
  final String allergies;
  final String medicalNotes;
  final String sosPin;
  final Map<String, dynamic>? deviceInfo;
  final bool locationPermissionGranted;
  final Map<String, dynamic>? lastKnownLocation;

  // Giữ alias tương thích
  String? get telegramUsername => telegramId;

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    String? telegramId,
    String? bloodType,
    String? allergies,
    String? medicalNotes,
    String? sosPin,
    Map<String, dynamic>? deviceInfo,
    bool? locationPermissionGranted,
    Map<String, dynamic>? lastKnownLocation,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      telegramId: telegramId ?? this.telegramId,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      sosPin: sosPin ?? this.sosPin,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
    );
  }
}
