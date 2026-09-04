import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/profile_stats.dart';
import 'controller/profile_tab_controller.dart';

/// Profile — Figma "Profile/dashboard" (135:8098).
///
/// Read from the REST API, so paint opacity came through: the segmented-control
/// pills are outlined in #263238 at *50%*, not the solid black a naive read
/// gives. That is [PrimaryColors.segmentBorder].
///
/// The design frame carries no bottom navigation of its own — the shell
/// supplies it — and its content stops at y=492, leaving the lower half of the
/// 844 frame empty. That is the design, not a truncated export.
class ProfileTab extends GetView<ProfileTabController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            // The card and "My stats" sit at x=22; the header and the pills at
            // x=24, hence the 2px inset on those two rather than one padding
            // for everything. Top is 36 = the design's 83 less the 47-tall
            // status bar the frame includes and SafeArea already accounts for.
            padding: EdgeInsets.fromLTRB(22.h, 36.v, 22.h, 32.v),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.h),
                child: const _Header(),
              ),
              SizedBox(height: 24.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.h),
                child: const _SectionTabs(),
              ),
              SizedBox(height: 12.v),
              Text('My stats', style: CustomTextStyles.statsHeading),
              SizedBox(height: 16.v),
              const _StatsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // Avatar left, title centred in the remaining width — the design's 92px
    // gap is what centring the 110-wide label produces, so it is expressed as
    // centring rather than pinned, and survives a longer title.
    return Row(
      children: [
        // The Settings frame is named "Profile/setting", so it belongs under
        // Profile — but no frame shows how it opens. The avatar is the
        // inferred entry point; confirm with the designer, because otherwise
        // Settings is unreachable.
        InkWell(
          onTap: () => Get.toNamed(AppRoutes.settings),
          customBorder: const CircleBorder(),
          child: Container(
            width: 40.h,
            height: 40.h,
            decoration: BoxDecoration(
              color: appTheme.avatarBacking,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            // Artwork not exported; the backing circle is the design's own.
            child: Icon(
              Icons.person_outline,
              size: 22.h,
              color: appTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Profile',
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        // Balances the avatar so the title centres on the screen, not on the
        // space left over beside it.
        SizedBox(width: 40.h),
      ],
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileTabController>();
    // No Obx: with one pill state in the design there is nothing here that
    // varies with the selected section.
    return Row(
      children: [
        for (final s in controller.sections) ...[
          _SegmentPill(label: s.label, onTap: () => controller.select(s)),
          if (s != controller.sections.last) SizedBox(width: 8.h),
        ],
      ],
    );
  }
}

/// A section pill.
///
/// The design draws all three identically — it ships no selected state, so
/// none is invented here. That is a real gap in the design rather than an
/// omission in this build: nothing on the frame indicates which section is
/// showing. Revisit when History and Check-Ins are built, since by then the
/// control has to say where you are.
class _SegmentPill extends StatelessWidget {
  const _SegmentPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.h),
      child: Container(
        width: 82.h,
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(10.h),
          border: Border.all(color: appTheme.segmentBorder),
        ),
        child: Text(label, style: CustomTextStyles.segmentLabel),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileTabController>();
    return Container(
      height: 265.v,
      decoration: BoxDecoration(
        gradient: appTheme.statsCardGradient,
        borderRadius: BorderRadius.circular(16.h),
      ),
      // 57 top and bottom in the design; the button and the stat row are the
      // only two children, 25 apart.
      padding: EdgeInsets.symmetric(vertical: 57.v),
      child: Column(
        children: [
          _SessionButton(onTap: controller.openSessionNote),
          SizedBox(height: 25.v),
          Obx(() => _StatRow(stats: controller.stats.value)),
        ],
      ),
    );
  }
}

class _SessionButton extends StatelessWidget {
  const _SessionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        width: 256.h,
        height: 48.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // onPrimary, not surface: the card keeps the same brand gradient in
          // dark mode, so anything sitting on it must not follow the theme.
          // surface here is #423F3F in dark, which left the blue label
          // near-invisible against it.
          color: appTheme.onPrimary,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Text(
          'I had an amazing session',
          style: CustomTextStyles.statsActionLabel,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    // Centred with a 4px gap, not spread — the three columns occupy 253 of the
    // card's 346 and sit centred within it.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Stat(
          asset: ImageConstant.imgStatMeditation,
          label: 'Meditation minutes',
          value: stats.meditationMinutes,
          width: 95,
        ),
        SizedBox(width: 4.h),
        _Stat(
          asset: ImageConstant.imgStatBalance,
          label: 'Balance minutes',
          value: stats.balanceMinutes,
          width: 76,
        ),
        SizedBox(width: 4.h),
        _Stat(
          asset: ImageConstant.icLiveSession,
          label: 'Live sessions',
          value: stats.liveSessions,
          width: 82,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.asset,
    required this.label,
    required this.value,
    required this.width,
  });

  /// The exported glyph — a PNG for the two illustrated ones, an SVG for the
  /// live-session camera.
  final String asset;
  final String label;
  final int value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImageView(
            imagePath: asset,
            height: 20.h,
            width: 20.h,
          ),
          SizedBox(height: 8.v),
          // Fixed at the design's 28 — two lines — so the values below sit on
          // one line across all three columns whether or not a label wraps.
          SizedBox(
            height: 28.v,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: CustomTextStyles.statLabel,
              ),
            ),
          ),
          SizedBox(height: 8.v),
          Text('$value', style: CustomTextStyles.statLabel),
        ],
      ),
    );
  }
}
