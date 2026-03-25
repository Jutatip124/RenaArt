import 'package:flutter/foundation.dart';

/// Centralized logging service for proper error tracking and debugging.
/// Replaces silent error suppression with structured logging.
class LoggingService {
  LoggingService._();
  static final LoggingService instance = LoggingService._();

  /// Log levels for different types of messages
  static const String _debug = 'DEBUG';
  static const String _info = 'INFO';
  static const String _warning = 'WARNING';
  static const String _error = 'ERROR';

  /// Log debug information (development only)
  void debug(String message, {String? context, Object? data}) {
    if (kDebugMode) {
      _log(_debug, message, context: context, data: data);
    }
  }

  /// Log informational messages
  void info(String message, {String? context, Object? data}) {
    _log(_info, message, context: context, data: data);
  }

  /// Log warning messages (non-critical issues)
  void warning(String message, {String? context, Object? data}) {
    _log(_warning, message, context: context, data: data);
  }

  /// Log error messages (critical issues)
  void error(String message, {String? context, Object? error, StackTrace? stackTrace}) {
    _log(_error, message, context: context, data: error);
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _log(String level, String message, {String? context, Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? '[$context] ' : '';
    final dataStr = data != null ? '\nData: $data' : '';

    final logMessage = '[$timestamp] $level: $contextStr$message$dataStr';

    if (kDebugMode) {
      debugPrint(logMessage);
    }

    // In production, this would send to a logging service (e.g., Sentry, Firebase Crashlytics)
    // For now, we just print in debug mode
  }

  /// Log authentication-related events
  void authEvent(String event, {String? userId, Object? details}) {
    info('Auth: $event', context: userId, data: details);
  }

  /// Log data operations (CRUD)
  void dataOperation(String operation, {String? collection, Object? details}) {
    debug('Data: $operation', context: collection, data: details);
  }

  /// Log network errors
  void networkError(String operation, {Object? error}) {
    this.error('Network error during $operation', error: error);
  }

  /// Log storage errors
  void storageError(String operation, {Object? error}) {
    this.error('Storage error during $operation', error: error);
  }
}
