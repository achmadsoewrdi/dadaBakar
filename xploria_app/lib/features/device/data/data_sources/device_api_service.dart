import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/device_profile_model.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

class DeviceApiService {
  static final DeviceApiService _instance = DeviceApiService._internal();
  factory DeviceApiService() => _instance;
  DeviceApiService._internal();

  final String baseUrl = kIsWeb ? 'http://127.0.0.1:8000/api/v1' : 'http://192.168.1.71:8000/api/v1';

  Future<Map<String, String>> _getHeaders() async {
    final token = AuthStorageService().accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Tidak ada akses token. Silakan login kembali.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<DeviceProfileModel>> getDevices() async {
    final url = Uri.parse('$baseUrl/devices/');
    final headers = await _getHeaders();
    
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => DeviceProfileModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat perangkat (${response.statusCode})');
    }
  }

  Future<DeviceProfileModel> createDevice(DeviceProfileModel device) async {
    final url = Uri.parse('$baseUrl/devices/');
    final headers = await _getHeaders();
    
    final response = await http.post(
      url, 
      headers: headers,
      body: jsonEncode(device.toJson()),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return DeviceProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menyimpan perangkat (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    final url = Uri.parse('$baseUrl/devices/$deviceId');
    final headers = await _getHeaders();
    
    final response = await http.delete(url, headers: headers).timeout(const Duration(seconds: 10));
    
    if (response.statusCode != 204) {
      throw Exception('Gagal menghapus perangkat (${response.statusCode}): ${response.body}');
    }
  }

  Future<DeviceProfileModel> updateDevice(String deviceId, Map<String, dynamic> updateData) async {
    final url = Uri.parse('$baseUrl/devices/$deviceId');
    final headers = await _getHeaders();
    
    final response = await http.put(
      url, 
      headers: headers,
      body: jsonEncode(updateData),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return DeviceProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memperbarui perangkat (${response.statusCode}): ${response.body}');
    }
  }
}
