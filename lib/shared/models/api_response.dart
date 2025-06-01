import 'package:json_annotation/json_annotation.dart';
import 'package:vyral/core/utils/logger.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    try {
      // Handle different response formats
      bool success = true;
      String? message;
      T? data;
      Map<String, dynamic>? errors;
      Map<String, dynamic>? meta;

      AppLogger.debug('🔍 Parsing ApiResponse from JSON: $json');

      // Check for explicit success field
      if (json.containsKey('success')) {
        success = json['success'] == true;
      } else if (json.containsKey('status')) {
        success = json['status'] == 'success' || json['status'] == true;
      }

      // Extract message
      message = json['message']?.toString() ?? json['msg']?.toString();

      // Extract data
      if (json.containsKey('data')) {
        final dataValue = json['data'];
        AppLogger.debug('🔍 Found data field: $dataValue');

        if (dataValue != null) {
          try {
            data = fromJsonT(dataValue);
          } catch (e) {
            AppLogger.debug('❌ Error parsing data field: $e');
            // If parsing fails, try to return the raw data
            if (T == dynamic) {
              data = dataValue as T?;
            } else {
              rethrow;
            }
          }
        }
      } else if (!json.containsKey('success') && !json.containsKey('status')) {
        // If no wrapper, treat the whole response as data
        AppLogger.debug('🔍 No wrapper found, treating whole response as data');
        try {
          data = fromJsonT(json);
        } catch (e) {
          AppLogger.debug('❌ Error parsing whole response as data: $e');
          if (T == dynamic) {
            data = json as T?;
          } else {
            rethrow;
          }
        }
      }

      // Extract errors
      if (json['errors'] is Map<String, dynamic>) {
        errors = json['errors'] as Map<String, dynamic>;
      }

      // Extract meta/pagination
      if (json['meta'] is Map<String, dynamic>) {
        meta = json['meta'] as Map<String, dynamic>;
      } else if (json['pagination'] is Map<String, dynamic>) {
        meta = json['pagination'] as Map<String, dynamic>;
      }

      AppLogger.debug(
          '🔍 Parsed ApiResponse - success: $success, hasData: ${data != null}, message: $message');

      return ApiResponse<T>(
        success: success,
        message: message,
        data: data,
        errors: errors,
        meta: meta,
      );
    } catch (e) {
      AppLogger.debug('❌ Failed to parse API response: $e');
      AppLogger.debug('❌ JSON data: $json');
      throw FormatException('Failed to parse API response: $e');
    }
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  // Helper constructors
  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error({
    String? message,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }

  // Safe data extraction
  T? get safeData {
    try {
      return data;
    } catch (e) {
      return null;
    }
  }

  // Check if response has data
  bool get hasData => data != null;

  // Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;
}
