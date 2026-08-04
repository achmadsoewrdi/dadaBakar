import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/repositories/i_account_repository.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';
import '../../../../core/config/app_constants.dart';

class AccountRepository implements IAccountRepository {
  @override
  Future<UserModel?> getUserProfile() async {
    return AuthStorageService().currentUser;
  }

  @override
  Future<UserModel> updateProfile(String fullName, File? photo) async {
    final token = AuthStorageService().accessToken;
    if (token == null) {
      throw Exception('Tidak ada token autentikasi.');
    }

    final uri = Uri.parse('${AppConstants.apiBaseUrl}/auth/me');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['full_name'] = fullName;

    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(responseBody);
      final updatedUser = UserModel.fromJson(jsonResponse);
      
      // Update local storage
      await AuthStorageService().updateUser(updatedUser);
      
      return updatedUser;
    } else {
      final jsonResponse = jsonDecode(responseBody);
      throw Exception(jsonResponse['detail'] ?? 'Gagal memperbarui profil');
    }
  }
}
