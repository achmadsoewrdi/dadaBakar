import '../../../auth/domain/models/user_model.dart';

abstract class IAccountRepository {
  Future<UserModel?> getUserProfile();
}
