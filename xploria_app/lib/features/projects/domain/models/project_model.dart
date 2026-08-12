class ProjectModel {
  final String id;
  final String ownerId;
  final String name;
  final String workspaceXml;
  final String? generatedCode;
  final String deviceType; // 'raspberry_pi' | 'orange_pi'
  final String? moduleCategory;
  final List<Map<String, dynamic>>? blynkConfigJson; // Blynk IoT widget layout configuration
  final String? moduleCategory; // 'drone' | 'smart_home' | dll
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ProjectModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.workspaceXml,
    this.generatedCode,
    required this.deviceType,
    this.moduleCategory,
    this.blynkConfigJson,
    this.moduleCategory,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      workspaceXml: json['workspace_xml'] as String? ?? '',
      generatedCode: (json['generated_code'] is Map)
          ? (json['generated_code'] as Map)['python'] as String?
          : json['generated_code'] as String?,
      deviceType: json['device_type'] as String? ?? 'raspberry_pi',
      moduleCategory: json['subject_context'] as String?,
      blynkConfigJson: (json['blynk_config_json'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      moduleCategory: json['module_category'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'workspace_xml': workspaceXml,
      'generated_code': generatedCode,
      'device_type': deviceType,
      'subject_context': moduleCategory,
      'blynk_config_json': blynkConfigJson,
      'module_category': moduleCategory,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? workspaceXml,
    String? generatedCode,
    String? deviceType,
    String? moduleCategory,
    List<Map<String, dynamic>>? blynkConfigJson,
    String? moduleCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      workspaceXml: workspaceXml ?? this.workspaceXml,
      generatedCode: generatedCode ?? this.generatedCode,
      deviceType: deviceType ?? this.deviceType,
      moduleCategory: moduleCategory ?? this.moduleCategory,
      blynkConfigJson: blynkConfigJson ?? this.blynkConfigJson,
      moduleCategory: moduleCategory ?? this.moduleCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
