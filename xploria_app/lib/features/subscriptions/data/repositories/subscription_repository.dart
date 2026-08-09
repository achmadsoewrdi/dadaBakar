import '../data_sources/subscription_remote_data_source.dart';
import '../models/subscription_model.dart';
import '../../domain/models/subscription_tier.dart';
import '../../domain/repositories/i_subscription_repository.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepository({SubscriptionRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? SubscriptionRemoteDataSource();

  @override
  Future<SubscriptionModel> getMySubscription() {
    return _remoteDataSource.getMySubscription();
  }

  @override
  Future<SubscriptionModel> subscribe(SubscriptionTier tier) {
    return _remoteDataSource.subscribe(tier);
  }
}
