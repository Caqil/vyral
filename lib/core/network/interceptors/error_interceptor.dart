import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );
        break;
      case DioExceptionType.badResponse:
        exception = _handleBadResponse(err);
        break;
      case DioExceptionType.cancel:
        exception = const NetworkException(message: 'Request cancelled');
        break;
      case DioExceptionType.connectionError:
        exception = const NetworkException(
          message: 'No internet connection. Please check your network.',
        );
        break;
      case DioExceptionType.badCertificate:
        exception = const NetworkException(
          message: 'Certificate verification failed',
        );
        break;
      case DioExceptionType.unknown:
        exception = NetworkException(
          message: err.message ?? 'An unexpected error occurred',
        );
        break;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  Exception _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    String message = 'An error occurred';
    Map<String, List<String>>? validationErrors;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;

      // Handle validation errors
      if (data['errors'] is Map<String, dynamic>) {
        validationErrors = {};
        final errors = data['errors'] as Map<String, dynamic>;
        errors.forEach((key, value) {
          if (value is List) {
            validationErrors![key] = value.cast<String>();
          } else if (value is String) {
            validationErrors![key] = [value];
          }
        });
      }
    }

    switch (statusCode) {
      case 400:
        if (validationErrors != null) {
          return ValidationException(
            message: message,
            errors: validationErrors,
          );
        }
        return ServerException(message: message, statusCode: statusCode);
      case 401:
        return AuthException(
          message: message.isEmpty ? 'Unauthorized access' : message,
          type: 'unauthorized',
        );
      case 403:
        return AuthException(
          message: message.isEmpty ? 'Access forbidden' : message,
          type: 'forbidden',
        );
      case 404:
        return ServerException(
          message: message.isEmpty ? 'Resource not found' : message,
          statusCode: statusCode,
        );
      case 422:
        return ValidationException(
          message: message,
          errors: validationErrors,
        );
      case 429:
        return ServerException(
          message: message.isEmpty ? 'Too many requests' : message,
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message.isEmpty
              ? 'Server error. Please try again later.'
              : message,
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
    }
  }
}
