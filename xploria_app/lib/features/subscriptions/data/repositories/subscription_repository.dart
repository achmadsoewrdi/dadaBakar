import '../data_sources/subscription_remote_data_source.dart';
import '../models/subscription_model.dart';


class SubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource = SubscriptionRemoteDataSource();
  

  Future<SubscriptionModel> getMySubscription() async {
    final sub = await _remoteDataSource.getMySubscription();
    // Cache the premium status in the auth storage if we want to
    // For simplicity we could just save a boolean indicating premium status
    // or rely on fetching this each time the app loads
    return sub;
  }

  Future<SubscriptionModel> subscribe(String tier) async {
    return await _remoteDataSource.subscribe(tier);
  }
}
