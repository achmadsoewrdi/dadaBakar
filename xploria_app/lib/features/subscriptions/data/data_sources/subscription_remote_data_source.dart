import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_constants.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';
import '../models/subscription_model.dart';
import '../../domain/models/subscription_tier.dart';

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
      throw Exception('Failed to load subscription status: ${response.statusCode}');
    }
  }

  Future<SubscriptionModel> subscribe(SubscriptionTier tier) async {
    final token = _authStorage.accessToken;
    if (token == null) throw Exception('No token found');

    final response = await http
        .post(
          Uri.parse('$_baseUrl/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'tier': tier.value}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return SubscriptionModel.fromJson(json.decode(response.body));
    } else {
      final body = json.decode(response.body);
      throw Exception(body['detail'] ?? 'Gagal membuat langganan: ${response.statusCode}');
    }
  }
}
