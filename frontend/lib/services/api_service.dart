import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiService {
  final http.Client _client;
  final FlutterSecureStorage _storage;
  String? _accessToken;

  ApiService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<void> _loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    _accessToken = accessToken;
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    _accessToken = null;
  }

  Future<Map<String, String>> _getHeaders() async {
    await _loadTokens();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<http.Response> _refreshAccessToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refresh}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['accessToken'], data['refreshToken']);
    }

    return response;
  }

  Future<http.Response> _authenticatedRequest(
    Future<http.Response> Function() requestFn,
  ) async {
    try {
      return await requestFn();
    } catch (e) {
      // Try to refresh token and retry
      try {
        final refreshResponse = await _refreshAccessToken();
        if (refreshResponse.statusCode == 200) {
          return await requestFn();
        }
      } catch (refreshError) {
        await _clearTokens();
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['accessToken'], data['refreshToken']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken != null) {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
        headers: headers,
        body: jsonEncode({'refreshToken': refreshToken}),
      );
    }
    await _clearTokens();
  }

  // Device methods
  Future<List<dynamic>> getDevices() async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.devices}'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load devices: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getDevice(String id) async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.device(id)}'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load device: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createDevice(String name) async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.devices}'),
      headers: headers,
      body: jsonEncode({'name': name}),
    ));

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create device: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateDevice(String id, String name) async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.put(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.device(id)}'),
      headers: headers,
      body: jsonEncode({'name': name}),
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update device: ${response.body}');
    }
  }

  Future<void> deleteDevice(String id) async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.delete(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.device(id)}'),
      headers: headers,
    ));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete device: ${response.body}');
    }
  }

  // Dashboard methods
  Future<List<dynamic>> getDashboardOverview() async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboardOverview}'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard: ${response.body}');
    }
  }

  // Sensor methods
  Future<List<dynamic>> getDeviceReadings(String deviceId, {int? limit}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deviceReadings(deviceId)}')
        .replace(queryParameters: limit != null ? {'limit': limit.toString()} : null);
    
    final response = await _authenticatedRequest(() => _client.get(
      uri,
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load readings: ${response.body}');
    }
  }

  // Pump control methods
  Future<Map<String, dynamic>> sendPumpCommand(
    String deviceId,
    String commandId,
    bool isOn,
    int durationSeconds,
  ) async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pumpCommands(deviceId)}'),
      headers: headers,
      body: jsonEncode({
        'commandId': commandId,
        'isOn': isOn,
        'durationSeconds': durationSeconds,
      }),
    ));

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send pump command: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getPumpCommands(
    String deviceId, {
    int page = 1,
    int pageSize = 20,
    int? rangeHours,
  }) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (rangeHours != null) {
      queryParams['rangeHours'] = rangeHours.toString();
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pumpCommandHistory(deviceId)}')
        .replace(queryParameters: queryParams);

    final response = await _authenticatedRequest(() => _client.get(
      uri,
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load pump commands: ${response.body}');
    }
  }

  Future<List<dynamic>> getPumpSchedules(String deviceId) async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pumpSchedules(deviceId)}'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load pump schedules: ${response.body}');
    }
  }

  // Alert methods
  Future<Map<String, dynamic>> getAlertSettings(String deviceId) async {
    final headers = await _getHeaders();
    final response = await _authenticatedRequest(() => _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.alertSettings(deviceId)}'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load alert settings: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAlerts(
    String deviceId, {
    String status = 'all',
    int page = 1,
    int pageSize = 20,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.alerts(deviceId)}')
        .replace(queryParameters: {
      'status': status,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    final response = await _authenticatedRequest(() => _client.get(
      uri,
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load alerts: ${response.body}');
    }
  }
}