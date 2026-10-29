import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../data/models/session_mode.dart';

/// "How do you want to have your sessions?" — Figma `259:38702`.
///
/// The design asks this once, inside the therapy questionnaire, and the
/// answer went nowhere: every booking was sent as a video call whatever
/// was chosen, and the Pilates & Core and Stretch & Restore flows never
/// asked at all. It is a step of the booking now, so the answer reaches
/// the session it is about.
///
/// Answers with the chosen [SessionMode], or null if backed out — the
/// booking is made by the caller, so leaving here books nothing.
class SessionModeScreen extends StatefulWidget {
  const SessionModeScreen({super.key, this.initial});

  /// What to open on. Their last choice, where there is one.
  final SessionMode? initial;

  @override
  State<SessionModeScreen> createState() => _SessionModeScreenState();
}

class _SessionModeScreenState extends State<SessionModeScreen> {
  late SessionMode _chosen = widget.initial ?? SessionMode.fallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 18.v),
              Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 18.h,
                      width: 18.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.v),
              Text(
                'How do you want to have your sessions?',
                style: CustomTextStyles.breatheHeading,
              ),
              SizedBox(height: 12.v),
              Text(
                'You can change this with your coach once the session '
                'starts.',
                style: CustomTextStyles.emptyStateBody,
              ),
              SizedBox(height: 32.v),
              for (final mode in SessionMode.values) ...[
                _ModeTile(
                  mode: mode,
                  selected: _chosen == mode,
                  onTap: () => setState(() => _chosen = mode),
                ),
                SizedBox(height: 16.v),
              ],
              const Spacer(),
              CustomElevatedButton(
                text: 'Continue',
                onPressed: () => Get.back<SessionMode>(result: _chosen),
              ),
              SizedBox(height: 28.v),
            ],
          ),
        ),
      ),
    );
  }
}

/// One choice — the icon the questionnaire draws over its label.
class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final SessionMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.v),
        decoration: BoxDecoration(
          color: selected ? appTheme.spaceTag : appTheme.surface,
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(
            color: selected ? appTheme.soothifyBlue : appTheme.optionBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CustomImageView(
              imagePath: mode.icon,
              height: 24.h,
              width: 24.h,
              color: selected ? appTheme.soothifyBlue : appTheme.textPrimary,
            ),
            SizedBox(width: 16.h),
            Expanded(
              child: Text(mode.label, style: CustomTextStyles.statsHeading),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                size: 22.h,
                color: appTheme.soothifyBlue,
              ),
          ],
        ),
      ),
    );
  }
}
