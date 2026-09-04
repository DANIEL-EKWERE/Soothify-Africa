import 'package:get/get.dart';

import 'errors/app_exception.dart';
import 'utils/feedback_utils.dart';
import 'utils/logger.dart';

/// Shared loading/error plumbing for controllers.
///
/// Exists so no controller repeats a try/catch/snackbar block per method —
/// the pattern that made the reference project expensive to change. Subclasses
/// call [guard] and describe only the work that is actually theirs.
abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rxn<AppException> error = Rxn<AppException>();

  bool get hasError => error.value != null;

  /// Runs [action] with loading state, error typing, and user feedback handled.
  ///
  /// Returns null on failure so callers can branch without catching. Set
  /// [showFeedback] to false when a screen renders the error inline instead.
  Future<T?> guard<T>(
    Future<T> Function() action, {
    bool showFeedback = true,
    bool setLoading = true,
  }) async {
    if (setLoading) isLoading.value = true;
    error.value = null;
    try {
      return await action();
    } on AppException catch (e, s) {
      Log.e('guarded call failed', error: e, stackTrace: s);
      error.value = e;
      if (showFeedback) AppFeedback.error(e);
      return null;
    } catch (e, s) {
      Log.e('unexpected failure', error: e, stackTrace: s);
      final wrapped = const UnknownException();
      error.value = wrapped;
      if (showFeedback) AppFeedback.error(wrapped);
      return null;
    } finally {
      if (setLoading) isLoading.value = false;
    }
  }
}
