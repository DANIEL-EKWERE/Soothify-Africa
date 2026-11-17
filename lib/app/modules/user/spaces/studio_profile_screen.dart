import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/checkout_launcher.dart';
import '../../../data/models/passport_reservation.dart';
import '../../../data/models/space_listing.dart';
import '../../../data/repositories/spaces_repository.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../passport/widgets/reserve_sheet.dart';
import 'widgets/passport_sheet.dart';
import 'widgets/space_card.dart';

/// "Studio Profile & Direct Connect Screen" — Figma `282:25339`.
///
/// A 390x318 photograph with a "1/5" counter at (321, 236), then a sheet from
/// 306 carrying a 36x4 grab handle at 318, a 73-square avatar at (25, 342)
/// beside the name and location, the tags at 393, the blurb at 427, a row of
/// three 108x95 gallery frames at 489, the two actions at 608.5 and 668.5,
/// and a 12pt teaser at 745.
class StudioProfileScreen extends StatelessWidget {
  const StudioProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final space = Get.arguments as SpaceListing?;
    if (space == null) {
      // Reached without a studio -- a deep link, or a stale route. Say so
      // rather than drawing somebody else's studio.
      return Scaffold(
        backgroundColor: appTheme.background,
        body: Center(child: Text('spaces.notListed'.tr)),
      );
    }

    return Scaffold(
      backgroundColor: appTheme.background,
      body: Stack(
        children: [
          CustomImageView(
            imagePath: space.photoUrl,
            height: 318.v,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 24.h,
            top: 70.v,
            child: Row(
              children: [
                InkWell(
                  onTap: Get.back,
                  child: CustomImageView(
                    imagePath: ImageConstant.icBack,
                    height: 24.h,
                    width: 24.h,
                    color: appTheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 321.h,
            top: 236.v,
            child: const _Counter(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _Sheet(space: space),
          ),
        ],
      ),
    );
  }
}

/// "1/5" over the photograph — 45x27 on ink at 72%.
class _Counter extends StatelessWidget {
  const _Counter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27.v,
      width: 45.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Ink that stays dark: this washes over a photograph, and
        // `textPrimary` inverted it to near-white under the white count.
        color: appTheme.onFixedLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Text('1/5', style: CustomTextStyles.studioCounter),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.space});

  final SpaceListing space;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 538 puts the sheet's top at 306, which is 12 above the photograph's
      // lower edge — the overlap is what makes the rounded corners read as a
      // sheet lifted over the picture rather than a seam.
      height: 538.v,
      // It had no radius at all: square corners cutting straight across the
      // photograph. 16 measured off the designer's screenshot, top corners
      // only.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: appTheme.onPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.v),
          Center(
            child: Container(
              height: 4.v,
              width: 36.h,
              decoration: BoxDecoration(
                color: appTheme.sheetHandle,
                borderRadius: BorderRadius.circular(4.h),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 24.v),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomImageView(
                      imagePath: space.photoUrl,
                      height: 73.h,
                      width: 73.h,
                      fit: BoxFit.cover,
                      radius: BorderRadius.circular(3.65.h),
                    ),
                    SizedBox(width: 18.h),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(space.name, style: CustomTextStyles.spaceName),
                          SizedBox(height: 8.v),
                          // The frame separates these with an asterisk.
                          Text(
                            // The distance is only known when the phone
                            // shared where it is.
                            space.distanceKm == null
                                ? space.area
                                : '${space.area} • '
                                    '${space.distanceKm!.toStringAsFixed(0)}km',
                            style: CustomTextStyles.studioLocation,
                          ),
                          SizedBox(height: 8.v),
                          Wrap(
                            spacing: 8.h,
                            runSpacing: 4.v,
                            children: [
                              for (final t in space.tags) SpaceTag(t),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.v),
                Text(space.about, style: CustomTextStyles.studioAbout),
                SizedBox(height: 24.v),
                SizedBox(
                  height: 95.v,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        Expanded(
                          child: CustomImageView(
                            imagePath: space.photoUrl,
                            height: 95.v,
                            fit: BoxFit.cover,
                            radius: BorderRadius.circular(8.h),
                          ),
                        ),
                        if (i < 2) SizedBox(width: 8.h),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.5.v),
                CustomElevatedButton(
                  text: 'Connect on Instagram',
                  onPressed: () async {
                    final opened =
                        await ExternalLink.instagram(space.instagram);
                    if (!opened) {
                      AppFeedback.error(
                        'Could not open @${space.instagram}.',
                      );
                    }
                  },
                ),
                SizedBox(height: 8.v),
                CustomElevatedButton(
                  text: 'Call Studio Desk',
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.surface,
                    foregroundColor: appTheme.actionFill,
                    elevation: 0,
                    side: BorderSide(color: appTheme.actionFill),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                  ),
                  labelStyle: CustomTextStyles.studioSecondaryAction,
                  onPressed: () async {
                    // Opens the dialler with the number in it; pressing
                    // call is the person's own decision.
                    final opened = await ExternalLink.call(space.phone);
                    if (!opened) {
                      AppFeedback.error('No number on file for this studio.');
                    }
                  },
                ),
                SizedBox(height: 24.5.v),
                _UpcomingSessions(space: space),
                SizedBox(height: 24.5.v),
                const _PassportTeaser(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Love this studio? Get early access to Passport passes".
///
/// The frame styles this as one text node with two runs — the question in
/// body ink and everything from "Get" in `#2F6FED`, which makes the second
/// half a link. It carries no prototype interaction, so where it went was an
/// open question until the designer gave the sheet's copy; it opens
/// [PassportSheet].
class _PassportTeaser extends StatelessWidget {
  const _PassportTeaser();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PassportSheet.show(context),
      behavior: HitTestBehavior.opaque,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Love this studio? ',
              style: CustomTextStyles.studioTeaser,
            ),
            TextSpan(
              text: 'Get early access to Passport passes',
              style: CustomTextStyles.studioTeaserLink,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// "Upcoming sessions" — the studio's Passport classes, each with its own
/// way in.
///
/// Only what the studio has opened to Passport members: a class with no
/// allocation is the studio's own business and does not appear here. A full
/// one does appear, with its button spent — a class that is full is
/// information, and hiding it reads as the studio having nothing on.
class _UpcomingSessions extends StatefulWidget {
  const _UpcomingSessions({required this.space});

  final SpaceListing space;

  @override
  State<_UpcomingSessions> createState() => _UpcomingSessionsState();
}

class _UpcomingSessionsState extends State<_UpcomingSessions> {
  List<StudioSession>? _sessions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows =
          await Get.find<SpacesRepository>().sessions(widget.space.id);
      if (mounted) setState(() => _sessions = rows);
    } on AppException {
      // The rest of the profile is still worth reading, so a studio whose
      // timetable cannot be reached simply shows none.
      if (mounted) setState(() => _sessions = const []);
    }
  }

  Future<void> _reserve(StudioSession session) async {
    final held = await ReserveSheet.show(
      context,
      sessionId: session.id,
      studioName: widget.space.name,
    );
    if (held == null) return;
    await Get.toNamed(
      AppRoutes.passportReservation,
      arguments: {'reservation': held, 'justBooked': true},
    );
    // The class has one fewer place now, and may have none.
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions;
    if (sessions == null || sessions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('passport.upcomingSessions'.tr,
            style: CustomTextStyles.spaceName),
        SizedBox(height: 16.v),
        for (final session in sessions) ...[
          _SessionCard(
            session: session,
            cover: widget.space.photoUrl,
            onReserve: () => _reserve(session),
          ),
          SizedBox(height: 12.v),
        ],
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.cover,
    required this.onReserve,
  });

  final StudioSession session;
  final String cover;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageView(
            imagePath: cover,
            height: 72.h,
            width: 72.h,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(8.h),
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title, style: CustomTextStyles.spaceName),
                SizedBox(height: 4.v),
                Text(
                  '${DateFormat('EEE, d MMM').format(session.startsAt)} · '
                  '${DateFormat('h:mm a').format(session.startsAt)}',
                  style: CustomTextStyles.studioLocation,
                ),
                SizedBox(height: 10.v),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: session.isFull ? null : onReserve,
                    borderRadius: BorderRadius.circular(8.h),
                    child: Container(
                      height: 44.v,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: session.isFull
                            ? appTheme.cardRim
                            : appTheme.actionFill,
                        borderRadius: BorderRadius.circular(8.h),
                      ),
                      child: Text(
                        session.isFull
                            ? 'passport.classFull'.tr
                            : 'passport.reserveSpace'.tr,
                        style: CustomTextStyles.subscribeLabel.copyWith(
                          color: session.isFull
                              ? appTheme.textMuted
                              : appTheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
