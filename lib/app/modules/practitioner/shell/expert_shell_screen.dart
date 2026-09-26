import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_tab.dart';
import '../../user/shell/widgets/app_bottom_nav.dart';
import '../dashboard/expert_dashboard_screen.dart';
import '../earnings/expert_earnings_tab.dart';
import '../notes/expert_notes_tab.dart';
import '../profile/expert_profile_tab.dart';
import '../schedule/expert_schedule_tab.dart';
import 'controller/expert_shell_controller.dart';

/// The expert role's shell — five tabs behind one bottom navigation bar, as
/// every frame in the expert row draws it.
///
/// An IndexedStack, like the client shell, so a tab keeps its scroll position
/// when you move away and back.
class ExpertShellScreen extends GetView<ExpertShellController> {
  const ExpertShellScreen({super.key});

  /// Exhaustive on purpose — no default — so a sixth destination fails to
  /// compile here rather than silently falling back to a placeholder.
  static Widget _tabView(ExpertTab tab) => switch (tab) {
        ExpertTab.home => const ExpertDashboardScreen(),
        ExpertTab.schedule => const ExpertScheduleTab(),
        ExpertTab.earnings => const ExpertEarningsTab(),
        ExpertTab.notes => const ExpertNotesTab(),
        ExpertTab.profile => const ExpertProfileTab(),
      };

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: appTheme.background,
        body: IndexedStack(
          index: controller.index,
          children: [
            for (final tab in controller.tabs) _tabView(tab),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          tabs: controller.tabs,
          currentIndex: controller.index,
          onSelected: controller.select,
        ),
      ),
    );
  }
}
