import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/models/auth_response_model.dart';
import '../data_sources/auth_api_service.dart';

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

  Future<AuthResponseModel> loginWithGoogle([String? providedIdToken]) async {
    if (providedIdToken != null) {
      return _apiService.loginWithGoogle(idToken: providedIdToken);
    }

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '508119791160-6hebpitsnbh0qs5995fk5bo49t9ocqlj.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );
    
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('Login Google dibatalkan oleh pengguna.');
      }
      
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('Gagal mendapatkan ID Token dari Google. Pastikan Web Client ID sudah benar dan SHA-1 sudah terdaftar.');
      }
      
      return await _apiService.loginWithGoogle(idToken: idToken);
    } catch (e) {
      await googleSignIn.signOut();
      rethrow;
    }
  }
}

