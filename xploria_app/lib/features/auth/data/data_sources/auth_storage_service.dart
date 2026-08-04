import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/auth_response_model.dart';
import '../../domain/models/user_model.dart';

class AuthStorageService {
  static final AuthStorageService _instance = AuthStorageService._internal();
  factory AuthStorageService() => _instance;
  AuthStorageService._internal();

  final _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  UserModel? _currentUser;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  /// Inisialisasi: Membaca token dari storage saat aplikasi baru dibuka
  Future<void> init() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    
    final userJsonStr = await _storage.read(key: 'current_user');
    if (userJsonStr != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJsonStr));
      } catch (e) {
        _currentUser = null;
      }
    }
  }

  Future<void> saveAuthSession(AuthResponseModel authResponse) async {
    _accessToken = authResponse.accessToken;
    _refreshToken = authResponse.refreshToken;
    _currentUser = authResponse.user;

    await _storage.write(key: 'access_token', value: _accessToken);
    await _storage.write(key: 'refresh_token', value: _refreshToken);
    await _storage.write(key: 'current_user', value: jsonEncode(_currentUser!.toJson()));
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'current_user');
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isPremium: isPremium);
      await _storage.write(key: 'current_user', value: jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _storage.write(key: 'current_user', value: jsonEncode(_currentUser!.toJson()));
  }
}
