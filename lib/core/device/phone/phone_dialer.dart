import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================================
/// FILE: lib/core/device/phone/phone_dialer.dart
/// MODULE: Core Device Phone Dialer Capability
/// ROLE:
///   Mở trình quay số hoặc thực hiện cuộc gọi GSM trực tiếp qua tel: URL.
/// ============================================================================

final phoneDialerProvider = Provider<PhoneDialer>((ref) {
  return PhoneDialer();
});

class PhoneDialer {
  /// Thực hiện cuộc gọi tới số điện thoại chỉ định
  Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Quay số điện thoại (alias cho makePhoneCall)
  Future<bool> dial(String phoneNumber) => makePhoneCall(phoneNumber);

  /// Gọi khẩn cấp Cảnh sát 113
  Future<bool> callPolice() => makePhoneCall('113');

  /// Gọi khẩn cấp Cấp cứu 115
  Future<bool> callAmbulance() => makePhoneCall('115');
}
