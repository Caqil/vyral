import 'dart:developer' as developer;

class AppLogger {
  static const String _name = 'SocialNetwork';

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 500, // Debug level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 800, // Info level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void severe(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 1200, // Severe level
      error: error,
      stackTrace: stackTrace,
    );
  }
}
