import '../../domain/repositories/i_account_repository.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

class AccountRepository implements IAccountRepository {
  @override
  Future<UserModel?> getUserProfile() async {
    return AuthStorageService().currentUser;
  }
}

