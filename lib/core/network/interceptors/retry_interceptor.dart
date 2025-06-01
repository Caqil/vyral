// lib/core/network/interceptors/retry_interceptor.dart
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final List<int> retryableStatusCodes;
  final List<DioExceptionType> retryableExceptionTypes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.retryableStatusCodes = const [
      HttpStatus.internalServerError, // 500
      HttpStatus.badGateway, // 502
      HttpStatus.serviceUnavailable, // 503
      HttpStatus.gatewayTimeout, // 504
      HttpStatus.requestTimeout, // 408
      HttpStatus.tooManyRequests, // 429
    ],
    this.retryableExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Get retry count from request options (defaults to 0)
    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    // Check if we should retry this request
    if (_shouldRetry(err, retryCount)) {
      try {
        print(
            '🔄 Retrying request (${retryCount + 1}/$maxRetries): ${err.requestOptions.path}');

        // Calculate delay with exponential backoff
        final delay = _calculateDelay(retryCount);
        await Future.delayed(delay);

        // Update retry count
        err.requestOptions.extra['retry_count'] = retryCount + 1;

        // Create new Dio instance to avoid interceptor loops
        final dio = Dio();

        // Copy the original request options
        final options = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          extra: err.requestOptions.extra,
          responseType: err.requestOptions.responseType,
          contentType: err.requestOptions.contentType,
          validateStatus: err.requestOptions.validateStatus,
          receiveDataWhenStatusError:
              err.requestOptions.receiveDataWhenStatusError,
          followRedirects: err.requestOptions.followRedirects,
          maxRedirects: err.requestOptions.maxRedirects,
          requestEncoder: err.requestOptions.requestEncoder,
          responseDecoder: err.requestOptions.responseDecoder,
        );

        // Retry the request
        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: options,
        );

        print('✅ Retry successful for: ${err.requestOptions.path}');
        handler.resolve(response);
        return;
      } catch (retryError) {
        print('❌ Retry failed for: ${err.requestOptions.path}');
        // If retry fails, continue with original error
      }
    }

    // No more retries or not retryable, pass the original error
    handler.next(err);
  }

  /// Determine if the request should be retried
  bool _shouldRetry(DioException err, int retryCount) {
    // Don't retry if we've reached max retries
    if (retryCount >= maxRetries) {
      return false;
    }

    // Don't retry certain methods (unless explicitly allowed)
    if (!_isRetryableMethod(err.requestOptions.method)) {
      return false;
    }

    // Check if the exception type is retryable
    if (retryableExceptionTypes.contains(err.type)) {
      return true;
    }

    // Check if the status code is retryable
    if (err.response?.statusCode != null &&
        retryableStatusCodes.contains(err.response!.statusCode)) {
      return true;
    }

    return false;
  }

  /// Check if the HTTP method is safe to retry
  bool _isRetryableMethod(String method) {
    // Generally safe to retry idempotent methods
    const retryableMethods = ['GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS'];
    return retryableMethods.contains(method.toUpperCase());
  }

  /// Calculate delay using exponential backoff with jitter
  Duration _calculateDelay(int retryCount) {
    // Exponential backoff: baseDelay * 2^retryCount
    final exponentialDelay = baseDelay * pow(2, retryCount);

    // Add jitter (random factor) to avoid thundering herd
    final jitter = Random().nextDouble() * 0.1; // 0-10% jitter
    final totalDelayMs = exponentialDelay.inMilliseconds * (1 + jitter);

    // Cap the maximum delay to avoid extremely long waits
    const maxDelayMs = 30000; // 30 seconds
    final cappedDelayMs = min(totalDelayMs, maxDelayMs);

    return Duration(milliseconds: cappedDelayMs.round());
  }
}
