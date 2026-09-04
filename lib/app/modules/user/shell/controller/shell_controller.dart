import '../../../../core/app_export.dart';
import '../../../../data/models/app_tab.dart';

/// Owns which tab is showing.
///
/// Kept deliberately thin: each tab manages its own state through its own
/// controller, so switching tabs must not reset anything.
class ShellController extends GetxController {
  final Rx<AppTab> current = AppTab.home.obs;

  List<AppTab> get tabs => AppTab.values;

  int get index => current.value.index;

  void select(int i) => current.value = AppTab.values[i];
}
