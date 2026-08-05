import '../../domain/models/project_model.dart';
import '../data_sources/project_api_service.dart';

class ProjectRepositoryImpl {
  final ProjectApiService _apiService = ProjectApiService();

  Future<List<ProjectModel>> getProjects() {
    return _apiService.getProjects();
  }

  Future<ProjectModel> createProject(String name, {String workspaceXml = '<xml xmlns="https://developers.google.com/blockly/xml"></xml>'}) {
    return _apiService.createProject(name, workspaceXml: workspaceXml);
  }

  Future<ProjectModel> updateProject(String projectId, {
    String? name,
    String? workspaceXml,
    String? generatedCode,
    List<dynamic>? blynkConfigJson,
  }) {
    return _apiService.updateProject(
      projectId,
      name: name,
      workspaceXml: workspaceXml,
      generatedCode: generatedCode,
      blynkConfigJson: blynkConfigJson,
    );
  }

  Future<void> deleteProject(String projectId) {
    return _apiService.deleteProject(projectId);
  }
}
