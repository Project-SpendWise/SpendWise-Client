import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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

  Map<String, String> get _downloadHeaders {
    // For downloads, don't set Content-Type - let the server set it
    final headers = <String, String>{};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    // Accept any content type for downloads
    headers['Accept'] = '*/*';
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
      debugPrint('Downloading file: $fileId');
      debugPrint('URL: ${ApiConstants.buildUrl(ApiConstants.filesDownload(fileId))}');
      
      // Use a request to have more control over the connection
      final request = http.Request(
        'GET',
        Uri.parse(ApiConstants.buildUrl(ApiConstants.filesDownload(fileId))),
      );
      
      // Add headers
      request.headers.addAll(_downloadHeaders);
      
      // Send request and get streamed response
      final streamedResponse = await _client.send(request);
      
      debugPrint('Download response status: ${streamedResponse.statusCode}');
      debugPrint('Download response headers: ${streamedResponse.headers}');
      
      // Check for Connection header issues
      final connectionHeaders = streamedResponse.headers['connection'] ?? '';
      if (connectionHeaders.toLowerCase().contains('close')) {
        debugPrint('WARNING: Server sent Connection: close header. This may cause premature connection closure.');
        debugPrint('Backend should use Connection: keep-alive or omit the header entirely.');
      }
      
      if (streamedResponse.statusCode == 200) {
        // Get content type and length first
        final contentType = streamedResponse.headers['content-type'] ?? '';
        final contentLength = streamedResponse.headers['content-length'];
        
        debugPrint('Content-Type: $contentType');
        debugPrint('Content-Length: $contentLength');
        
        // Read the response stream into bytes manually in chunks
        // This is more reliable than toBytes() for large files
        final bytes = <int>[];
        final expectedLength = contentLength != null ? int.tryParse(contentLength) : null;
        
        try {
          // Read stream in chunks manually - more reliable than toBytes()
          final completer = Completer<void>();
          final subscription = streamedResponse.stream.listen(
            (chunk) {
              bytes.addAll(chunk);
              if (bytes.length % 100000 == 0 || (expectedLength != null && bytes.length == expectedLength)) {
                debugPrint('Received ${bytes.length}${expectedLength != null ? '/$expectedLength' : ''} bytes');
              }
            },
            onError: (error) {
              debugPrint('Stream error: $error');
              if (!completer.isCompleted) {
                completer.completeError(error);
              }
            },
            onDone: () {
              debugPrint('Stream completed. Total bytes: ${bytes.length}');
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
            cancelOnError: false,
          );
          
          // Wait for stream to complete with timeout
          await completer.future.timeout(
            const Duration(seconds: 120),
            onTimeout: () {
              subscription.cancel();
              throw TimeoutException(
                'Download timeout: Reading file data took too long',
                const Duration(seconds: 120),
              );
            },
          );
        } on TimeoutException catch (e) {
          debugPrint('Timeout reading stream: $e');
          throw ApiError(
            message: 'Download timeout: The file download took too long. Received ${bytes.length} bytes.',
            statusCode: 200,
          );
        } catch (e) {
          debugPrint('Error reading stream chunks: $e');
          if (bytes.isEmpty) {
            throw ApiError(
              message: 'Failed to read file data: $e',
              statusCode: 200,
            );
          }
          // If we got some data, continue with what we have
          debugPrint('Warning: Stream closed early, but got ${bytes.length} bytes');
        }
        
        debugPrint('Downloaded ${bytes.length} bytes (expected: ${expectedLength ?? 'unknown'})');
        
        // Validate that we got actual data
        if (bytes.isEmpty) {
          debugPrint('ERROR: Downloaded file is empty');
          throw ApiError(
            message: 'Downloaded file is empty',
            statusCode: 200,
          );
        }
        
        // Check if this is a ZIP-based file (XLSX, DOCX, etc.) - these are very sensitive to missing bytes
        final isZipBasedFile = bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B; // PK (ZIP signature)
        
        // Validate content length if provided
        if (expectedLength != null) {
          if (bytes.length == expectedLength) {
            debugPrint('Download complete: ${bytes.length} bytes (100% match)');
          } else {
            final difference = expectedLength - bytes.length;
            final percentage = (bytes.length / expectedLength) * 100;
            
            debugPrint('Content-Length mismatch detected:');
            debugPrint('  Expected: $expectedLength bytes');
            debugPrint('  Received: ${bytes.length} bytes');
            debugPrint('  Difference: $difference bytes');
            debugPrint('  Completion: ${percentage.toStringAsFixed(4)}%');
            debugPrint('  File type: ${isZipBasedFile ? "ZIP-based (XLSX/DOCX) - requires exact match" : "Other"}');
            
            if (bytes.length < expectedLength) {
              // ZIP-based files (XLSX, DOCX) require exact match - missing bytes corrupt the archive
              if (isZipBasedFile) {
                debugPrint('✗ ZIP-based file incomplete - requires exact match');
                throw ApiError(
                  message: 'Incomplete download: XLSX/DOCX files require exact match. Received ${bytes.length} of $expectedLength bytes (missing $difference bytes). Please try downloading again.',
                  statusCode: 200,
                );
              }
              
              // For other files, allow small discrepancies (<= 100 bytes OR >= 99.9% complete)
              // This handles cases where the connection closes just before the last few bytes
              final shouldAccept = difference <= 100 || percentage >= 99.9;
              
              if (shouldAccept) {
                debugPrint('✓ Accepting download despite small discrepancy:');
                debugPrint('  - Missing: $difference bytes (${(difference / expectedLength * 100).toStringAsFixed(4)}%)');
                debugPrint('  - Complete: ${percentage.toStringAsFixed(4)}%');
                debugPrint('  - File should still be usable');
                // Continue with the bytes we have - file should still be valid
              } else {
                // For larger discrepancies, this is a real problem
                debugPrint('✗ Download incomplete - too much data missing');
                throw ApiError(
                  message: 'Incomplete download: Received ${bytes.length} of $expectedLength bytes (${percentage.toStringAsFixed(2)}% complete, missing $difference bytes)',
                  statusCode: 200,
                );
              }
            } else {
              // Received more than expected - shouldn't happen but log it
              debugPrint('WARNING: Received more bytes than expected (${bytes.length - expectedLength} extra)');
              // Accept it anyway - extra data shouldn't break the file
            }
          }
        }
        
        // Check if response might be JSON (error or wrapped response)
        if (contentType.contains('application/json') || 
            (bytes.isNotEmpty && bytes.length < 10000 && _isJsonResponse(bytes))) {
          try {
            final text = utf8.decode(bytes);
            debugPrint('Response appears to be JSON: ${text.substring(0, text.length > 200 ? 200 : text.length)}');
            
            final json = jsonDecode(text) as Map<String, dynamic>;
            
            // Check if it's a wrapped response with file data
            if (json.containsKey('data')) {
              final data = json['data'];
              if (data is Map<String, dynamic>) {
                // If there's a base64 encoded file
                if (data.containsKey('file') && data['file'] is String) {
                  debugPrint('Found base64 encoded file in response');
                  return base64Decode(data['file'] as String);
                }
                // If there's file bytes directly
                if (data.containsKey('bytes') && data['bytes'] is List) {
                  debugPrint('Found file bytes array in response');
                  return List<int>.from(data['bytes'] as List);
                }
              } else if (data is String) {
                // Base64 encoded file in data field
                debugPrint('Found base64 encoded file in data field');
                return base64Decode(data);
              }
            }
            
            // Check if it's an error response
            if (json.containsKey('error')) {
              debugPrint('Error in JSON response: ${json['error']}');
              throw ApiError(
                message: json['error'] is Map 
                    ? (json['error'] as Map)['message']?.toString() ?? 'Download failed'
                    : json['error'].toString(),
                statusCode: json['error'] is Map 
                    ? (json['error'] as Map)['statusCode'] as int?
                    : 200,
                errorCode: json['error'] is Map 
                    ? (json['error'] as Map)['errorCode']?.toString()
                    : null,
              );
            }
            
            // Unknown JSON format
            debugPrint('Unexpected JSON format: $json');
            throw ApiError(
              message: 'Unexpected JSON response format. Expected file binary data.',
              statusCode: 200,
            );
          } catch (e) {
            if (e is ApiError) rethrow;
            // If JSON parsing fails, might be binary data with wrong content-type
            debugPrint('JSON parsing failed, treating as binary: $e');
            // Continue to return bytes
          }
        }
        
        // Check if response might still be JSON (even if content-type doesn't say so)
        // This can happen if backend returns JSON error with wrong content-type
        if (bytes.length > 0 && bytes.length < 5000) {
          try {
            final text = utf8.decode(bytes);
            if (text.trim().startsWith('{') || text.trim().startsWith('[')) {
              final json = jsonDecode(text) as Map<String, dynamic>;
              debugPrint('Response is JSON despite binary expectation: $text');
              
              // Check for error
              if (json.containsKey('error')) {
                throw ApiError(
                  message: json['error'] is Map 
                      ? (json['error'] as Map)['message']?.toString() ?? 'Download failed'
                      : json['error'].toString(),
                  statusCode: json['error'] is Map 
                      ? (json['error'] as Map)['statusCode'] as int?
                      : 200,
                );
              }
              
              // Check for wrapped file data
              if (json.containsKey('data')) {
                final data = json['data'];
                if (data is String) {
                  // Base64 encoded
                  debugPrint('Found base64 file in data field');
                  return base64Decode(data);
                } else if (data is Map<String, dynamic>) {
                  if (data.containsKey('file') && data['file'] is String) {
                    debugPrint('Found base64 file in data.file field');
                    return base64Decode(data['file'] as String);
                  }
                }
              }
              
              throw ApiError(
                message: 'Unexpected JSON response. Expected binary file data.',
                statusCode: 200,
              );
            }
          } catch (e) {
            if (e is ApiError) rethrow;
            // Not JSON, continue
          }
        }
        
        // Check if it's actually a PDF/Excel/CSV by checking magic bytes
        if (bytes.length >= 4) {
          final magicBytes = bytes.take(4).toList();
          debugPrint('File magic bytes: $magicBytes');
          
          // PDF: %PDF
          if (magicBytes[0] == 0x25 && magicBytes[1] == 0x50 && magicBytes[2] == 0x44 && magicBytes[3] == 0x46) {
            debugPrint('Detected PDF file');
          }
          // ZIP (XLSX/DOCX): PK (0x50 0x4B)
          else if (magicBytes[0] == 0x50 && magicBytes[1] == 0x4B) {
            debugPrint('Detected ZIP-based file (XLSX/DOCX)');
          }
          // XLS: D0 CF 11 E0
          else if (magicBytes[0] == 0xD0 && magicBytes[1] == 0xCF && magicBytes[2] == 0x11 && magicBytes[3] == 0xE0) {
            debugPrint('Detected XLS file');
          }
          // CSV/Text: Check if it's readable text
          else {
            try {
              final text = utf8.decode(bytes.take(100).toList());
              if (text.contains(',') || text.contains('\n')) {
                debugPrint('Detected text/CSV file');
              }
            } catch (e) {
              // Not text
            }
          }
        }
        
        debugPrint('Successfully downloaded file: ${bytes.length} bytes');
        return bytes;
      } else {
        // Handle error response
        final errorBytes = await streamedResponse.stream.toBytes();
        final errorResponse = http.Response.bytes(
          errorBytes,
          streamedResponse.statusCode,
          headers: streamedResponse.headers,
          request: streamedResponse.request,
        );
        
        debugPrint('Download failed with status: ${streamedResponse.statusCode}');
        _handleErrorResponse(errorResponse);
        throw ApiError(
          message: 'Failed to download file',
          statusCode: streamedResponse.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('ClientException during download: $e');
      debugPrint('This usually means the connection was closed prematurely');
      throw ApiError(
        message: 'Connection error: The server closed the connection while downloading. This might be due to:\n'
            '1. File is too large\n'
            '2. Server timeout\n'
            '3. Network interruption\n'
            'Please check your backend supports streaming downloads and includes Content-Length header.',
        statusCode: null,
      );
    } catch (e, stackTrace) {
      debugPrint('Download error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: $e');
    }
  }

  /// Check if response bytes look like JSON
  bool _isJsonResponse(List<int> bytes) {
    if (bytes.isEmpty) return false;
    try {
      final text = utf8.decode(bytes.take(100).toList());
      return text.trim().startsWith('{') || text.trim().startsWith('[');
    } catch (e) {
      return false;
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

