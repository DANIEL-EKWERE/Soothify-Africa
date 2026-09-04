import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/app_tab.dart';
import 'controller/shell_controller.dart';
import '../community/community_tab.dart';
import '../discovery/discovery_tab.dart';
import '../plans/plans_tab.dart';
import '../profile/profile_tab.dart';
import 'tabs/home_tab.dart';
import 'widgets/app_bottom_nav.dart';

/// The signed-in shell: five tabs behind one bottom navigation bar.
///
/// An IndexedStack rather than swapping the body, so each tab keeps its scroll
/// position and state when you move away and back — which is what the design's
/// persistent nav implies.
///
/// The bar is 74 tall, as measured; its colours and icons still come from the
/// app's tokens rather than the design — see [AppBottomNav].
class ShellScreen extends GetView<ShellController> {
  const ShellScreen({super.key});

  /// Every tab now has its own screen. The switch is exhaustive on purpose —
  /// no default — so adding a sixth destination fails to compile here rather
  /// than silently falling back to a placeholder.
  static Widget _tabView(AppTab tab) => switch (tab) {
        AppTab.home => const HomeTab(),
        AppTab.plans => const PlansTab(),
        AppTab.discovery => const DiscoveryTab(),
        AppTab.community => const CommunityTab(),
        AppTab.profile => const ProfileTab(),
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
