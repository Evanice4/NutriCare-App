import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'api_routes.dart';

/// HTTP API Client for making REST API requests
/// This handles all HTTP communication with backend services
class HttpApiClient {
  static final HttpApiClient _instance = HttpApiClient._internal();
  factory HttpApiClient() => _instance;
  HttpApiClient._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 30);

  /// Get authentication token from Firebase Auth
  Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  /// Get headers with authentication if user is logged in
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = ApiRoutes.getDefaultHeaders();

    if (requireAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle HTTP response and parse JSON
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final statusCode = response.statusCode;
      final body = utf8.decode(response.bodyBytes);

      // Handle empty responses
      if (body.isEmpty) {
        if (statusCode >= 200 && statusCode < 300) {
          return ApiResponse.success(null);
        } else {
          return ApiResponse.error(
            'Empty response with status code: $statusCode',
          );
        }
      }

      // Parse JSON response
      final jsonData = json.decode(body);

      if (statusCode >= 200 && statusCode < 300) {
        // Success response
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data == null) {
              return ApiResponse.success(null);
            }
            return ApiResponse.success(fromJson(data));
          }
          return ApiResponse.success(fromJson(jsonData));
        } else if (jsonData is List) {
          // Handle list responses - this would need to be handled differently
          return ApiResponse.success(null);
        }
        return ApiResponse.success(null);
      } else {
        // Error response
        String errorMessage = 'Request failed with status: $statusCode';
        if (jsonData is Map<String, dynamic>) {
          errorMessage =
              jsonData['message'] ??
              jsonData['error'] ??
              jsonData['detail'] ??
              errorMessage;
        }
        return ApiResponse.error(errorMessage, statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }

  /// Handle HTTP response for list data
  Future<ApiResponse<List<T>>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final statusCode = response.statusCode;
      final body = utf8.decode(response.bodyBytes);

      if (body.isEmpty) {
        if (statusCode >= 200 && statusCode < 300) {
          return ApiResponse.success([]);
        } else {
          return ApiResponse.error(
            'Empty response with status code: $statusCode',
          );
        }
      }

      final jsonData = json.decode(body);

      if (statusCode >= 200 && statusCode < 300) {
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          final data = jsonData['data'];
          if (data is List) {
            final items = data
                .cast<Map<String, dynamic>>()
                .map((item) => fromJson(item))
                .toList();
            return ApiResponse.success(items);
          }
        } else if (jsonData is List) {
          final items = jsonData
              .cast<Map<String, dynamic>>()
              .map((item) => fromJson(item))
              .toList();
          return ApiResponse.success(items);
        }
        return ApiResponse.success([]);
      } else {
        String errorMessage = 'Request failed with status: $statusCode';
        if (jsonData is Map<String, dynamic>) {
          errorMessage =
              jsonData['message'] ??
              jsonData['error'] ??
              jsonData['detail'] ??
              errorMessage;
        }
        return ApiResponse.error(errorMessage, statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParams,
    bool requireAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(ApiRoutes.buildQuery(url, queryParams ?? {}));
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await _client
          .get(uri, headers: headers)
          .timeout(_timeout);

      if (fromJson != null) {
        return await _handleResponse<T>(response, fromJson);
      } else {
        // For simple responses without JSON parsing
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse.success(null);
        } else {
          return ApiResponse.error(
            'Request failed with status: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP request failed');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Generic GET request for lists
  Future<ApiResponse<List<T>>> getList<T>(
    String url, {
    Map<String, dynamic>? queryParams,
    bool requireAuth = true,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final uri = Uri.parse(ApiRoutes.buildQuery(url, queryParams ?? {}));
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await _client
          .get(uri, headers: headers)
          .timeout(_timeout);

      return await _handleListResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP request failed');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, dynamic>? data,
    bool requireAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final body = data != null ? json.encode(data) : null;

      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(_timeout);

      if (fromJson != null) {
        return await _handleResponse<T>(response, fromJson);
      } else {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse.success(null);
        } else {
          return ApiResponse.error(
            'Request failed with status: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP request failed');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String url, {
    Map<String, dynamic>? data,
    bool requireAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final body = data != null ? json.encode(data) : null;

      final response = await _client
          .put(uri, headers: headers, body: body)
          .timeout(_timeout);

      if (fromJson != null) {
        return await _handleResponse<T>(response, fromJson);
      } else {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse.success(null);
        } else {
          return ApiResponse.error(
            'Request failed with status: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP request failed');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<void>> delete(
    String url, {
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error(
          'Delete failed with status: ${response.statusCode}',
        );
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP request failed');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Delete failed: $e');
    }
  }

  /// Upload file with multipart request
  Future<ApiResponse<T>> uploadFile<T>(
    String url,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
    bool requireAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = await _getHeaders(requireAuth: requireAuth);
      request.headers.addAll(headers);

      // Add file
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (fromJson != null) {
        return await _handleResponse<T>(response, fromJson);
      } else {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse.success(null);
        } else {
          return ApiResponse.error(
            'Upload failed with status: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('HTTP request failed');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Upload failed: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// API Response wrapper class
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T? data) {
    return ApiResponse._(isSuccess: true, data: data);
  }

  factory ApiResponse.error(String error, [int? statusCode]) {
    return ApiResponse._(
      isSuccess: false,
      error: error,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(data: $data)';
    } else {
      return 'ApiResponse.error(error: $error, statusCode: $statusCode)';
    }
  }
}
