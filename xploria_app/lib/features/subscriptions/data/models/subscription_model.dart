class SubscriptionModel {
  final String id;
  final String userId;
  final String tier;
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
      tier: json['tier'] ?? 'free',
      status: json['status'] ?? 'inactive',
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tier': tier,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isPremium => tier == 'premium' || tier == 'pro';
}
