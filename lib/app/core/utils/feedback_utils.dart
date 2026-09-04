import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../errors/app_exception.dart';
import 'logger.dart';
import '../../theme/theme_helper.dart';

/// Single place that turns a failure into something the user sees.
///
/// This exists so controllers never hand-roll snackbars. If the presentation
/// of an error needs to change, it changes here and nowhere else.
class AppFeedback {
  const AppFeedback._();

  static void error(Object error) {
    final message = error is AppException
        ? error.message
        : const UnknownException().message;
    _show(message, appTheme.error);
  }

  static void success(String message) => _show(message, appTheme.success);

  static void info(String message) => _show(message, appTheme.textSecondary);

  static void _show(String message, Color background) {
    // No overlay yet (failure before the first frame, or a widget test):
    // log it rather than throwing over the top of the real error.
    if (Get.context == null) {
      Log.d('feedback suppressed, no overlay: $message');
      return;
    }
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      message: message,
      backgroundColor: background,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }
}
