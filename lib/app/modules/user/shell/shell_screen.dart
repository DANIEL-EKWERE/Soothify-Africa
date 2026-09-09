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
class ShellScreen extends StatefulWidget {
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
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen>
    with SingleTickerProviderStateMixin {
  /// Replayed on every tab change, so switching tabs settles rather than
  /// cutting. The IndexedStack underneath is untouched, which is what keeps
  /// each tab's scroll position.
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  int _last = -1;

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShellController>();
    return Obx(() {
      final index = controller.index;
      if (index != _last) {
        _last = index;
        // Skipped on the first build so the shell does not fade in over the
        // route transition that already brought it here.
        if (!MediaQuery.disableAnimationsOf(context)) {
          _settle.forward(from: 0);
        }
      }
      return Scaffold(
        backgroundColor: appTheme.background,
        body: FadeTransition(
          opacity: Tween<double>(begin: 0.4, end: 1).animate(
            CurvedAnimation(parent: _settle, curve: Curves.easeOut),
          ),
          child: IndexedStack(
            index: index,
            children: [
              for (final tab in controller.tabs)
                ShellScreen._tabView(tab),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          tabs: controller.tabs,
          currentIndex: index,
          onSelected: controller.select,
        ),
      );
    });
  }
}
