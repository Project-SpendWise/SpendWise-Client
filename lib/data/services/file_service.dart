import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/file_model.dart';
import '../services/api_models.dart';
import '../../core/constants/api_constants.dart';

class FileService {
  final http.Client _client;
  String? _authToken;

  FileService({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Upload a file
  Future<FileModel> uploadFile({
    required String filePath,
    required String fileName,
    required List<int> fileBytes,
    String? description,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.buildUrl(ApiConstants.filesUpload)),
      );

      // Add authorization header
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      // Add description if provided
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        final fileJson = data['file'] as Map<String, dynamic>;
        return FileModel.fromJson(fileJson);
      } else {
        _handleErrorResponse(response);
        throw ApiError(
          message: 'File upload failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  /// Get list of files with pagination
  Future<FileListResponse> getFiles({
    String? fileType,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (fileType != null) {
        queryParams['file_type'] = fileType;
      }
      queryParams['page'] = page.toString();
      queryParams['per_page'] = perPage.toString();

      final uri = Uri.parse(ApiConstants.buildUrl(ApiConstants.filesList))
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return FileListResponse.fromJson(json);
      } else {
        _handleErrorResponse(response);
        throw ApiError(
          message: 'Failed to get files',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  /// Get file details
  Future<FileModel> getFileDetails(String fileId) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.buildUrl(ApiConstants.filesDetail(fileId))),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        final fileJson = data['file'] as Map<String, dynamic>;
        return FileModel.fromJson(fileJson);
      } else {
        _handleErrorResponse(response);
        throw ApiError(
          message: 'Failed to get file details',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  /// Download a file
  Future<List<int>> downloadFile(String fileId) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.buildUrl(ApiConstants.filesDownload(fileId))),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        _handleErrorResponse(response);
        throw ApiError(
          message: 'Failed to download file',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  /// Delete a file
  Future<void> deleteFile(String fileId) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.buildUrl(ApiConstants.filesDelete(fileId))),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return;
      } else {
        _handleErrorResponse(response);
        throw ApiError(
          message: 'Failed to delete file',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  void _handleErrorResponse(http.Response response) {
    try {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (errorJson.containsKey('error')) {
        final errorData = errorJson['error'] as Map<String, dynamic>;
        throw ApiError(
          message: errorData['message'] as String? ?? 'An error occurred',
          statusCode: errorData['statusCode'] as int? ?? response.statusCode,
          errorCode: errorData['errorCode'] as String?,
        );
      } else {
        throw ApiError.fromJson(errorJson);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(
        message: 'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}

