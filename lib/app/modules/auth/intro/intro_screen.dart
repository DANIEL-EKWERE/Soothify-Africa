import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/intro_slide.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/intro_controller.dart';
import 'widgets/page_dots.dart';

/// "Welcome to Soothify" onboarding carousel — Figma section
/// "Mobile / splash screen + Onboarding screen" (655:5253 / 5273 / 5294).
///
/// Positions from the design, measured inside the 390x844 frame: screen title
/// at 77, artwork at 132 (342 square), slide heading at 514, body at 554, dots
/// at 664, and the button at 702.
///
/// Only the artwork and the middle block change between panels, so the title,
/// dots and button sit outside the PageView and stay put as it scrolls.
///
/// The carousel advances on its own every few seconds and can still be
/// swiped; a manual swipe resets the timer so the page is never pulled out
/// from under a finger. It settles on the last slide rather than wrapping —
/// see [IntroController].
class IntroScreen extends GetView<IntroController> {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip sits above the title, right-aligned. The frame for this
            // carousel could not be read when it was added, so the placement
            // is the conventional one rather than a measured one.
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 24.h, top: 8.h),
                child: GestureDetector(
                  onTap: controller.skip,
                  behavior: HitTestBehavior.opaque,
                  child: Semantics(
                    button: true,
                    child: Text('Skip', style: CustomTextStyles.skipAction),
                  ),
                ),
              ),
            ),
            GradientText(
              'Welcome to Soothify',
              gradient: appTheme.titleGradient,
              textAlign: TextAlign.center,
              style: CustomTextStyles.onboardingScreenTitle,
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  // The carousel still advances under reduce motion; it cuts
                  // between slides instead of sliding.
                  controller.animateAutoAdvance =
                      !MediaQuery.disableAnimationsOf(context);
                  return PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.slides.length,
                    itemBuilder: (context, i) =>
                        _Slide(slide: controller.slides[i]),
                  );
                },
              ),
            ),
            Obx(
              () => PageDots(
                count: controller.slides.length,
                index: controller.index.value,
              ),
            ),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: CustomElevatedButton(
                text: 'Get started',
                onPressed: controller.start,
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final IntroSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          // The design draws a fixed 342 square, but pinning that height
          // overflows on anything shorter than the reference frame. Letting
          // the artwork take the slack keeps it 342 at design size and shrinks
          // it instead of breaking the layout.
          Expanded(
            child: Center(
              child: Image.asset(slide.assetPath, fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 16.h),
          GradientText(
            slide.title,
            gradient: appTheme.titleGradient,
            textAlign: TextAlign.center,
            style: CustomTextStyles.onboardingSlideTitle,
          ),
          SizedBox(height: 14.h),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: CustomTextStyles.onboardingBody,
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
