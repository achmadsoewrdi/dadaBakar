class UserModel {
  final String id;
  final String email;
  final String? googleSub;
  final String fullName;
  final String role; // 'user' | 'admin'
  final bool isPremium;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.googleSub,
    required this.fullName,
    this.role = 'user',
    this.isPremium = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      googleSub: json['google_sub'] as String?,
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      isPremium: json['is_premium'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'google_sub': googleSub,
      'full_name': fullName,
      'role': role,
      'is_premium': isPremium,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
