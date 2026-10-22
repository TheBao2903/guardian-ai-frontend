import '../../l10n/app_localizations.dart';

/// Translate only generated device names; preserve model names and user data.
extension ProfileDisplayLabels on AppLocalizations {
  String profileDeviceName(String name) => switch (name) {
        'Máy tính Windows' || 'Windows PC' => deviceWindowsPc,
        'Máy tính Apple Mac' || 'Apple Mac' => deviceAppleMac,
        'Thiết bị Android' || 'Android device' => deviceAndroid,
        'Trình duyệt Web' || 'Web browser' => deviceWebBrowser,
        'Thiết bị Guardian AI' || 'Guardian AI device' => deviceGuardian,
        'Thiết bị người dùng' || 'User device' => deviceUser,
        _ => name,
      };

  String? profileLocationLabel({
    double? latitude,
    double? longitude,
    double? accuracy,
    String? savedAddress,
  }) {
    // Render structured data in the current locale, rather than displaying a
    // generated GPS string stored when a different language was selected.
    if (latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite) {
      final approximate =
          accuracy != null && accuracy.isFinite && accuracy >= 1000;
      final digits = approximate ? 4 : 5;
      final coordinates =
          '${latitude.toStringAsFixed(digits)}, ${longitude.toStringAsFixed(digits)}';
      if (approximate) return locationNetworkLabel(coordinates);
      if (accuracy != null && accuracy.isFinite && accuracy >= 0) {
        return locationGpsLabel(coordinates, accuracy.round().toString());
      }
      return coordinates;
    }
    // Legacy records may have only an address: preserve it instead of guessing
    // coordinates, accuracy or translating arbitrary user content.
    return savedAddress?.isNotEmpty == true ? savedAddress : null;
  }
}
