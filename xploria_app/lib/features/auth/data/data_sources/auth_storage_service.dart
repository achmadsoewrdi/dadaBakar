import '../../domain/models/auth_response_model.dart';
import '../../domain/models/user_model.dart';

class AuthStorageService {
  static final AuthStorageService _instance = AuthStorageService._internal();
  factory AuthStorageService() => _instance;
  AuthStorageService._internal();

  String? _accessToken;
  String? _refreshToken;
  UserModel? _currentUser;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  void saveAuthSession(AuthResponseModel authResponse) {
    _accessToken = authResponse.accessToken;
    _refreshToken = authResponse.refreshToken;
    _currentUser = authResponse.user;
  }

  void clearSession() {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
  }
}
