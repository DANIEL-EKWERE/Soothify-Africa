import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Thin logging wrapper. Everything is stripped in release builds so no
/// diagnostic output leaks to production.
class Log {
  const Log._();

  static void d(Object? message, {String name = 'soothify'}) {
    if (kDebugMode) developer.log('$message', name: name);
  }

  static void e(Object? message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        '$message',
        name: 'soothify',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }
}
