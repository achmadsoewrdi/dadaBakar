import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../../domain/device_entity.dart';
import '../../../../core/config/app_constants.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

class DeviceRemoteDataSource {
  String get _baseUrl {
    String url = AppConstants.apiBaseUrl;
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid && url.contains('127.0.0.1')) {
          url = url.replaceAll('127.0.0.1', '10.0.2.2');
        }
      } catch (_) {}
    }
    return '$url/devices';
  }

  Future<List<DeviceEntity>> getDevices() async {
    try {
      final token = AuthStorageService().accessToken;
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DeviceEntity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching devices: $e');
      return [];
    }
  }

  Future<DeviceEntity> saveDevice({
    required String label,
    required String protocol,
    String? host,
    int? port,
    String? macAddress,
  }) async {
    final token = AuthStorageService().accessToken;
    final response = await http.post(
      Uri.parse('$_baseUrl/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'label': label,
        'protocol': protocol,
        'host': ?host,
        'port': ?port,
        'mac_address': ?macAddress,
      }),
    );

    if (response.statusCode == 201) {
      return DeviceEntity.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to save device: ${response.statusCode} - ${response.body}');
    }
  }

  Future<bool> deleteDevice(String deviceId) async {
    try {
      final token = AuthStorageService().accessToken;
      final response = await http.delete(
        Uri.parse('$_baseUrl/$deviceId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete device: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting device: $e');
      return false;
    }
  }
}
