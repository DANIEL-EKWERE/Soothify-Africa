import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_recommendation.dart';
import '../../../data/models/expert_session.dart';

/// The expert's live session — Figma "Audio call with instructor" and
/// "video call with instructor", read from the expert's side.
///
/// Five controls, not the client's three: the expert can also open their
/// notes and recommend something mid-call. The frames show that last one as
/// two taps — "..." offers "Recommend Contents", and choosing it opens the
/// three kinds — so that is how it is built here.
class ExpertCallScreen extends StatefulWidget {
  const ExpertCallScreen({super.key, this.session});

  final ExpertSession? session;

  @override
  State<ExpertCallScreen> createState() => _ExpertCallScreenState();
}

/// Which step of the "..." menu is showing, if any.
enum _MenuStep { closed, offer, kinds }

class _ExpertCallScreenState extends State<ExpertCallScreen> {
  _MenuStep _menu = _MenuStep.closed;

  ExpertSession? get _session =>
      widget.session ??
      (Get.arguments is ExpertSession ? Get.arguments as ExpertSession : null);

  void _toggleMenu() => setState(() {
        _menu = _menu == _MenuStep.closed ? _MenuStep.offer : _MenuStep.closed;
      });

  void _recommend(ExpertContentKind kind) {
    setState(() => _menu = _MenuStep.closed);
    // Nothing sends a recommendation yet; saying so beats a dead control.
    AppFeedback.info('Recommending ${kind.label.toLowerCase()} is not built '
        'yet.');
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            ClipOval(
              child: CustomImageView(
                imagePath:
                    session?.avatarAsset ?? ImageConstant.imgHomeAvatar,
                height: 110.h,
                width: 110.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20.v),
            Text(session?.clientName ?? 'Your client',
                style: CustomTextStyles.joiningHeading),
            SizedBox(height: 8.v),
            // A fixed figure, as the frame draws it: no call is running, and
            // a ticking clock that counts nothing is a lie with a second
            // hand.
            Text('0:30', style: CustomTextStyles.expertBlurb),
            const Spacer(),
            if (_menu == _MenuStep.offer)
              _RecommendOffer(
                onTap: () => setState(() => _menu = _MenuStep.kinds),
              ),
            if (_menu == _MenuStep.kinds)
              _KindMenu(onPick: _recommend),
            SizedBox(height: 16.v),
            _Controls(
              onNotes: () => Get.toNamed(
                AppRoutes.expertSessionNotes,
                arguments: session,
              ),
              onMore: _toggleMenu,
              onPickOffer: () => setState(() => _menu = _MenuStep.kinds),
              menu: _menu,
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

/// The first step: a card naming what the "..." offers.
class _RecommendOffer extends StatelessWidget {
  const _RecommendOffer({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.v),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.v),
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(color: appTheme.cardRim),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ios_share, size: 18.h, color: appTheme.textPrimary),
              SizedBox(width: 10.h),
              Text('Recommend Contents',
                  style: CustomTextStyles.expertRowLabel),
            ],
          ),
        ),
      ),
    );
  }
}

/// The second: Video, Audio, Article.
class _KindMenu extends StatelessWidget {
  const _KindMenu({required this.onPick});

  final void Function(ExpertContentKind) onPick;

  IconData _glyph(ExpertContentKind kind) => switch (kind) {
        ExpertContentKind.video => Icons.videocam_outlined,
        ExpertContentKind.audio => Icons.graphic_eq,
        ExpertContentKind.article => Icons.article_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.v),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.v),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.cardRim),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video, Audio, Article — the frame's order, which is not the
            // enum's (that one is declared for the detail screen).
            for (final kind in const [
              ExpertContentKind.video,
              ExpertContentKind.audio,
              ExpertContentKind.article,
            ])
              InkWell(
                onTap: () => onPick(kind),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.v),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_glyph(kind),
                          size: 20.h, color: appTheme.textPrimary),
                      SizedBox(width: 14.h),
                      Text(kind.label,
                          style: CustomTextStyles.expertRowLabel),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.onNotes,
    required this.onMore,
    required this.onPickOffer,
    required this.menu,
  });

  final VoidCallback onNotes;
  final VoidCallback onMore;
  final VoidCallback onPickOffer;
  final _MenuStep menu;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Round(icon: Icons.mic_none, onTap: () {}),
        SizedBox(width: 14.h),
        _Round(icon: Icons.videocam_outlined, onTap: () {}),
        SizedBox(width: 14.h),
        _Round(icon: Icons.edit_outlined, onTap: onNotes),
        SizedBox(width: 14.h),
        _Round(
          icon: Icons.more_horiz,
          onTap: menu == _MenuStep.offer ? onPickOffer : onMore,
        ),
        SizedBox(width: 14.h),
        _Round(
          icon: Icons.call_end,
          onTap: Get.back,
          fill: appTheme.callEndFill,
          tint: appTheme.onPrimary,
        ),
      ],
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({
    required this.icon,
    required this.onTap,
    this.fill,
    this.tint,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? fill;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 56.h,
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill ?? appTheme.transparent,
          shape: BoxShape.circle,
          border: fill == null
              ? Border.all(color: appTheme.callControlRim)
              : null,
        ),
        child: Icon(icon, size: 24.h, color: tint ?? appTheme.textPrimary),
      ),
    );
  }
}
