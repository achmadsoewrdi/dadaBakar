import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/project_model.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

class ProjectApiService {
  static final ProjectApiService _instance = ProjectApiService._internal();
  factory ProjectApiService() => _instance;
  ProjectApiService._internal();

  final String baseUrl = 'http://192.168.1.68:8000/api/v1';

  Future<Map<String, String>> _getHeaders() FIX [DEVICE CONNECTION]: perbaikan ui modal bluetooth mencegah overflow dan mengubah alur auto-connect menjadi koneksi manualasync {
    final token = AuthStorageService().accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Tidak ada akses token. Silakan login kembali.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ProjectModel>> getProjects() async {
    final url = Uri.parse('$baseUrl/projects/');
    final headers = await _getHeaders();
    
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProjectModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat proyek (${response.statusCode})');
    }
  }

  Future<ProjectModel> createProject(String name, {String workspaceXml = '<xml xmlns="https://developers.google.com/blockly/xml"></xml>'}) async {
    final url = Uri.parse('$baseUrl/projects/');
    final headers = await _getHeaders();
    
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'workspace_xml': workspaceXml,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ProjectModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal membuat proyek baru (${response.statusCode})');
    }
  }

  Future<ProjectModel> updateProject(String projectId, {
    String? name,
    String? workspaceXml,
    String? generatedCode,
  }) async {
    final url = Uri.parse('$baseUrl/projects/$projectId');
    final headers = await _getHeaders();
    
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (workspaceXml != null) body['workspace_xml'] = workspaceXml;
    if (generatedCode != null) body['generated_code'] = generatedCode;
    
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ProjectModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menyimpan proyek (${response.statusCode})');
    }
  }

  Future<void> deleteProject(String projectId) async {
    final url = Uri.parse('$baseUrl/projects/$projectId');
    final headers = await _getHeaders();
    
    final response = await http.delete(url, headers: headers).timeout(const Duration(seconds: 10));
    
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Gagal menghapus proyek (${response.statusCode})');
    }
  }
}
