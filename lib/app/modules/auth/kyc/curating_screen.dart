import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/gradient_text.dart';

/// The last beat of the questionnaire — Figma "personalizing your
/// experience".
///
/// "Curating your sanctuary..." over a bar that fills, then the app. It is
/// theatre: the answers are already saved by the time this is shown, and the
/// bar is paced to be read rather than to track any real work. That is the
/// honest reading of a frame that shows a progress bar for a local write.
///
/// Three seconds, because the line is four words and a user who is told
/// something is being curated should see it happen rather than catch a flash.
class CuratingScreen extends StatefulWidget {
  const CuratingScreen({super.key});

  /// Where to go when the bar fills. Passed as the route's argument so the
  /// screen can end both the onboarding questionnaire and anything else that
  /// wants the same beat.
  static const fill = Duration(milliseconds: 3000);

  @override
  State<CuratingScreen> createState() => _CuratingScreenState();
}

class _CuratingScreenState extends State<CuratingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: CuratingScreen.fill,
  );

  @override
  void initState() {
    super.initState();
    // After the first frame, not during initState: _run reads MediaQuery,
    // and depending on an inherited widget before initState returns is an
    // error — which is exactly what the route smoke test caught.
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    // Under reduce motion the bar does not crawl; the screen still shows,
    // and still hands over.
    if (!mounted) return;
    final still = MediaQuery.disableAnimationsOf(context);
    if (!still) {
      await _progress.forward();
    } else {
      _progress.value = 1;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    if (!mounted) return;
    final next = Get.arguments is String
        ? Get.arguments as String
        : AppRoutes.shell;
    await Get.offAllNamed(next);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

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
              // The frame sets the line at 110 from the top, the bar 40
              // under it, and leaves the rest of the screen empty.
              SizedBox(height: 110.v),
              GradientText(
                'Curating your sanctuary...',
                gradient: appTheme.authHeaderGradient,
                style: CustomTextStyles.curatingHeading,
              ),
              SizedBox(height: 40.v),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4.h),
                  child: LinearProgressIndicator(
                    value: _progress.value,
                    minHeight: 8.v,
                    backgroundColor: appTheme.moodTrackInactive,
                    valueColor: AlwaysStoppedAnimation(appTheme.soothifyBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
