import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_constants.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';
import '../models/subscription_model.dart';

class SubscriptionRemoteDataSource {
  final AuthStorageService _authStorage = AuthStorageService();
  String get _baseUrl => '${AppConstants.apiBaseUrl}/subscriptions';

  Future<SubscriptionModel> getMySubscription() async {
    final token = _authStorage.accessToken;
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SubscriptionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load subscription status');
    }
  }

  Future<SubscriptionModel> subscribe(String tier) async {
    final token = _authStorage.accessToken;
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$_baseUrl/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'tier': tier}),
    );

    if (response.statusCode == 200) {
      return SubscriptionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to subscribe: ${response.body}');
    }
  }
}
