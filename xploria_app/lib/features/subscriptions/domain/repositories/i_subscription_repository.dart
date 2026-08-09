import '../../data/models/subscription_model.dart';
import '../models/subscription_tier.dart';

abstract class ISubscriptionRepository {
  /// Mengambil langganan aktif milik user.
  /// Throws [Exception] jika tidak ada langganan aktif atau request gagal.
  Future<SubscriptionModel> getMySubscription();

  /// Membuat langganan baru dengan [tier] yang dipilih.
  /// Throws [Exception] jika request ke backend gagal.
  Future<SubscriptionModel> subscribe(SubscriptionTier tier);
}
