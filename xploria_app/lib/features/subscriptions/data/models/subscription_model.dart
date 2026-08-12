import '../../domain/models/subscription_tier.dart';

class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final String status;
  final DateTime? expiresAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    this.expiresAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      tier: SubscriptionTier.fromValue(json['tier'] ?? 'premium'),
      status: json['status'] ?? 'inactive',
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tier': tier.value,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isPremium => tier.isPremium && isActive;
}

