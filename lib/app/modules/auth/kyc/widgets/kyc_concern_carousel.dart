import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/kyc_question.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../../../../widgets/step_progress_bar.dart';
import '../controller/kyc_controller.dart';

/// "What brings you to Soothify?" — Figma "Kyc screen | Stress"
/// (`176:23723`) and "| Anxiety" (`176:56150`).
///
/// A full-bleed screen in the focused option's own colour, with the
/// illustrations on a swipeable rail: the centre one large, its neighbours
/// peeking in at both edges. This is the onboarding mood picker, and it is a
/// different screen from the Mood Checker on Home, which is a slider.
///
/// Positions from the frame: progress 84 (4 tall), prompt 145.5, subtitle
/// 179.5, illustration band 297.5 (224 tall), label 562.5, button 697.
class KycConcernCarousel extends StatefulWidget {
  const KycConcernCarousel({super.key, required this.question});

  final KycQuestion question;

  @override
  State<KycConcernCarousel> createState() => _KycConcernCarouselState();
}

class _KycConcernCarouselState extends State<KycConcernCarousel> {
  /// Wide enough that both neighbours show at the edges, as the frame draws.
  late final PageController _rail = PageController(viewportFraction: 0.62);

  int _focused = 0;

  @override
  void dispose() {
    _rail.dispose();
    super.dispose();
  }

  KycOption get _option => widget.question.options[_focused];

  Color get _background => _option.backgroundArgb != null
      ? Color(_option.backgroundArgb!)
      // The two frames that have not been rendered yet fall back to the brand
      // colour rather than to nothing.
      : appTheme.brandDeep;

  Color get _accent => _option.accentArgb != null
      ? Color(_option.accentArgb!)
      : appTheme.onPrimary;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KycController>();
    final options = widget.question.options;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      // Fills the screen: sized to its child, the flood stopped short of the
      // bottom and the scaffold showed through under the button.
      width: double.infinity,
      height: double.infinity,
      color: _background,
      child: SafeArea(
        // Scrolls only as a guard: the stack below adds up to 755 of the
        // frame's 797 under the status bar, so nothing moves on the reference
        // device. A short surface scrolls instead of overflowing.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 37.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: StepProgressBar(
                  totalSteps: controller.totalSteps,
                  currentStep: controller.step.value + 1,
                  activeColor: _accent,
                ),
              ),
              SizedBox(height: 57.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.question.prompt,
                      style: CustomTextStyles.onboardingTitle.copyWith(
                        color: appTheme.onPrimary,
                      ),
                    ),
                    if (widget.question.subtitle != null) ...[
                      SizedBox(height: 15.v),
                      Text(
                        widget.question.subtitle!,
                        style: CustomTextStyles.onboardingSubtitle.copyWith(
                          color: appTheme.onPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 104.v),
              SizedBox(
                height: 224.v,
                child: PageView.builder(
                  controller: _rail,
                  itemCount: options.length,
                  onPageChanged: (i) => setState(() => _focused = i),
                  // Obx per item, not around the PageView: itemBuilder runs
                  // lazily, outside the scope an enclosing Obx would track, so
                  // a rail-level one observes nothing and the tick never shows.
                  itemBuilder: (context, i) => Obx(
                    () => _Figure(
                      option: options[i],
                      // The gender step comes first precisely so this can be
                      // answered by now.
                      artPath: options[i].illustrationFor(
                        controller.answers['gender']?.firstOrNull,
                      ),
                      focused: i == _focused,
                      selected: controller.current.contains(options[i].value),
                      onTap: () => controller.choose(options[i]),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 41.v),
              Text(
                _option.label,
                textAlign: TextAlign.center,
                style: CustomTextStyles.onboardingSlideTitle.copyWith(
                  color: appTheme.onPrimary,
                ),
              ),
              SizedBox(height: 119.5.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: Obx(
                  () => CustomElevatedButton(
                    text: 'Next',
                    isLoading: controller.isLoading.value,
                    isEnabled: controller.canProceed,
                    onPressed: controller.next,
                    // White on the flooded colour, with the brand blue as the
                    // label — the button's own style paints it white, which is
                    // invisible here.
                    labelStyle: CustomTextStyles.buttonLabel.copyWith(
                      color: appTheme.actionFill,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.onPrimary,
                      disabledBackgroundColor: appTheme.onPrimary.withValues(
                        alpha: 0.55,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.h),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48.v),
            ],
          ),
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.option,
    required this.artPath,
    required this.focused,
    required this.selected,
    required this.onTap,
  });

  final KycOption option;

  /// Already resolved for the user's gender.
  final String? artPath;
  final bool focused;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        // The neighbours are drawn smaller as well as clipped, which is what
        // makes the focused one read as in focus.
        scale: focused ? 1 : 0.72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The frame lights the focused figure from behind; the extracted
            // art carries no glow of its own.
            if (focused)
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      appTheme.onPrimary.withValues(alpha: 0.22),
                      appTheme.onPrimary.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: SizedBox(height: 224.v, width: 224.v),
              ),
            if (artPath != null)
              Image.asset(artPath!, fit: BoxFit.contain)
            else
              // Artwork pending a render; the label below still names it.
              const SizedBox.shrink(),
            if (selected && focused)
              Positioned(
                top: 0,
                right: 8.h,
                // The frames draw no selected state — they only ever show one
                // option in focus — so multi-select needs a mark of its own.
                child: Container(
                  height: 28.h,
                  width: 28.h,
                  decoration: BoxDecoration(
                    color: appTheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 18.h,
                    color: appTheme.brandDeep,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
