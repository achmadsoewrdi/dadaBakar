class LearningModuleModel {
  final String id;
  final String title;
  final String? description;
  final Map<String, dynamic> stepsJson;
  final bool isPremiumOnly;
  final DateTime createdAt;

  LearningModuleModel({
    required this.id,
    required this.title,
    this.description,
    required this.stepsJson,
    this.isPremiumOnly = false,
    required this.createdAt,
  });

  factory LearningModuleModel.fromJson(Map<String, dynamic> json) {
    return LearningModuleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      stepsJson: json['steps_json'] as Map<String, dynamic>? ?? {},
      isPremiumOnly: json['is_premium_only'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps_json': stepsJson,
      'is_premium_only': isPremiumOnly,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
