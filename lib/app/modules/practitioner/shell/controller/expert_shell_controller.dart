import '../../../../core/app_export.dart';
import '../../../../data/models/expert_tab.dart';

/// Owns which expert tab is showing.
///
/// Thin, like [ShellController]: each tab keeps its own state so switching
/// away and back resets nothing.
class ExpertShellController extends GetxController {
  final Rx<ExpertTab> current = ExpertTab.home.obs;

  List<ExpertTab> get tabs => ExpertTab.values;

  int get index => current.value.index;

  void select(int i) => current.value = ExpertTab.values[i];

  void show(ExpertTab tab) => current.value = tab;
}
