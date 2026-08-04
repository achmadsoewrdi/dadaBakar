import 'dart:io';
import '../../../auth/domain/models/user_model.dart';

abstract class IAccountRepository {
  Future<UserModel?> getUserProfile();
  Future<UserModel> updateProfile(String fullName, File? photo);
}
