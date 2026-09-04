import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';
import '../../../data/repositories/kyc_repository.dart';
import '../../../data/services/session_service.dart';
import 'start_route.dart';

/// Splash — brand gradient with the script wordmark, per the Figma design.
///
/// Deliberately a StatefulWidget rather than a GetView. The screen shows a
/// wordmark and never reads a controller, so a GetX controller behind it was
/// never constructed and the redirect never ran — the app sat here. initState
/// always runs, so the handoff cannot be skipped.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handOff();
  }

  Future<void> _handOff() async {
    final route = await resolveStartRoute(
      session: Get.find<SessionService>(),
      kyc: Get.find<KycRepository>(),
    );

    // Hold the brand moment, then leave. Guarded because the widget can be
    // disposed if something else navigates first.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Get.offAllNamed(route);
  }

  @override
  Widget build(BuildContext context) => const SplashView();
}

/// The splash's appearance, with no redirect attached.
///
/// Split out so it can be rendered — in a golden, or anywhere else — without
/// starting a timer or needing the session and KYC dependencies.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecoration.brandGradient,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          ImageConstant.svgWordmark,
          width: 194.h,
          semanticsLabel: 'Soothify',
        ),
      ),
    );
  }
}
