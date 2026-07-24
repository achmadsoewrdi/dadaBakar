class ProjectModel {
  final String id;
  final String ownerId;
  final String name;
  final String workspaceXml;
  final String? generatedCode;
  final String deviceType; // 'raspberry_pi' | 'orange_pi'
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
      generatedCode: json['generated_code'] as String?,
      deviceType: json['device_type'] as String? ?? 'raspberry_pi',
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
