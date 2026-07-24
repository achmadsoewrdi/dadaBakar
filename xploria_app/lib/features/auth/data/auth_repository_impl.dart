import '../domain/models/auth_response_model.dart';
import 'services/auth_api_service.dart';

class AuthRepositoryImpl {
  final AuthApiService _apiService = AuthApiService();

  Future<AuthResponseModel> loginWithEmail(String email, String password) {
    return _apiService.loginWithEmail(email: email, password: password);
  }

  Future<AuthResponseModel> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _apiService.registerWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<AuthResponseModel> loginWithGoogle([String? idToken]) {
    return _apiService.loginWithGoogle(idToken: idToken);
  }
}
