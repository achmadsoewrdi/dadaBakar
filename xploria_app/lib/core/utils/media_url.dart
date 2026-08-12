import '../config/app_constants.dart';

/// Mengubah URL foto profil relatif menjadi URL absolut.
///
/// Jika [rawUrl] sudah dimulai dengan 'http', dikembalikan apa adanya.
/// Jika relatif (mis. `/uploads/avatars/...`), disambungkan ke base URL
/// server tanpa suffix `/api/v1`.
///
/// Digunakan di: account_page.dart, dashboard_home_page.dart, edit_account_screen.dart
String resolveMediaUrl(String rawUrl) {
  if (rawUrl.startsWith('http')) return rawUrl;
  final serverBase = AppConstants.apiBaseUrl.replaceAll('/api/v1', '');
  return '$serverBase$rawUrl';
}
