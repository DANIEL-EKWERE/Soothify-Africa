import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import 'theme_helper.dart';

/// Type styles taken from the Figma design.
///
/// Both bundled faces are *variable* fonts, so weight is applied through
/// [FontVariation] on the `wght` axis. Setting only `fontWeight` would render
/// at the default 400 regardless of what is asked for.
class CustomTextStyles {
  const CustomTextStyles._();

  static const String fontNunito = 'Nunito';
  static const String fontNunitoSans = 'NunitoSans';
  static const String fontPacifico = 'Pacifico';

  static const List<FontVariation> _bold = [FontVariation('wght', 700)];
  static const List<FontVariation> _semiBold = [FontVariation('wght', 600)];
  static const List<FontVariation> _regular = [FontVariation('wght', 400)];

  /// "How do you feel today?" — Nunito Sans Bold 20, centred.
  static TextStyle get screenQuestion => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textBlack,
  );

  /// App bar title — Nunito Bold 16.
  static TextStyle get appBarTitle => appBarTitleFor(appTheme);

  static TextStyle appBarTitleFor(PrimaryColors c) => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: c.textPrimary,
  );

  /// Mood tile caption — Nunito Sans Bold 10, tracking -0.2, line height 1.3.
  static TextStyle get tileCaption => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    letterSpacing: -0.2,
    height: 1.3,
    color: appTheme.textPrimary,
  );

  /// Onboarding heading — Nunito Sans Bold 20, line height 1.3, tracking -0.2.
  /// Painted with a gradient in the design; see [GradientText].
  static TextStyle get onboardingTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 1.3,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// The concern carousel's question, which the frame fits on one line.
  ///
  /// Its own size rather than [onboardingTitle]'s 20: this project's bundled
  /// face sets wider than Figma's, and at 20 "What brings you to your space
  /// today?" broke onto a second line the design does not have. The plain KYC
  /// questions keep the 20, so they are unaffected.
  static TextStyle get carouselPrompt => onboardingTitle.copyWith(
        fontSize: 18.fSize,
      );

  /// "You Can Select More Than One Option" — Nunito Regular 16, tracking 0.3.
  static TextStyle get onboardingSubtitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 1.5,
    letterSpacing: 0.3,
    color: appTheme.textSubtitle,
  );

  /// "Welcome to Soothify" — Nunito Sans Bold 24, gradient filled.
  static TextStyle get onboardingScreenTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 31.2 / 24,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// Slide heading ("Personalized Therapy") — Nunito Sans Bold 20, gradient.
  /// The second sentence of the language screen's heading — Figma
  /// `259:25756` sets "Choose your preferred language." at weight **300**
  /// inside the same text node as the bold question above it.
  static TextStyle get onboardingSlideSubtitle =>
      onboardingSlideTitle.copyWith(
        fontWeight: FontWeight.w300,
        fontVariations: const [FontVariation('wght', 300)],
      );

  /// The intro carousel's "Skip" — quiet, so it does not compete with the
  /// primary action at the foot of the screen.
  static TextStyle get skipAction => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: const [FontVariation('wght', 600)],
    color: appTheme.textSubtitle,
  );

  static TextStyle get onboardingSlideTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 20,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// Slide body — Nunito Regular 16, line height 24, tracking 0.3.
  static TextStyle get onboardingBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 24 / 16,
    letterSpacing: 0.3,
    color: appTheme.textSubtitle,
  );

  /// Secondary full-width button label ("Skip") — Nunito Sans SemiBold 16.
  static TextStyle get secondaryButtonLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// Language option row — Nunito Regular 14 at 72% ink, centred.
  static TextStyle get languageOption => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.8 / 14,
    color: appTheme.textMuted,
  );

  /// Unselected value in the age wheel — Nunito Regular 14 at 50%.
  static TextStyle get wheelItem => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 21 / 14,
    letterSpacing: 0.3,
    color: appTheme.textSubtitle.withValues(alpha: 0.5),
  );

  /// Centred value in the age wheel — Nunito ExtraBold 24 at 90%.
  /// "Age" and "yrs" flanking the number on `259:27860` — Nunito Regular 16,
  /// muted, both the same.
  static TextStyle get ageReadoutLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textSubtitle,
  );

  /// The derived age itself, the largest type in the app.
  static TextStyle get ageReadoutValue => TextStyle(
    fontFamily: fontNunito,
    fontSize: 72.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 1,
    color: appTheme.textPrimary,
  );

  /// An unselected year on the birth-year wheel. Larger and darker than the
  /// old age wheel's neighbours ([wheelItem]) — the render shows them plainly
  /// readable rather than faded to half.
  static TextStyle get yearWheelItem => TextStyle(
    fontFamily: fontNunito,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textSubtitle,
  );

  /// The boxed year under the marker.
  static TextStyle get yearWheelSelected => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get wheelSelected => TextStyle(
    fontFamily: fontNunito,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    height: 36 / 24,
    letterSpacing: 0.3,
    color: appTheme.textSubtitle,
  );

  /// "Create your account" — Nunito Sans SemiBold 24.
  static TextStyle get authHeading => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 28.8 / 24,
    color: appTheme.authHeading,
  );

  /// Reassurance line under the auth heading — Nunito Regular 14 at 80%.
  static TextStyle get authBlurb => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.8 / 14,
    letterSpacing: 0.17,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  /// Caption above a filled input — Nunito Regular 14 at 72% ink.
  static TextStyle get inputLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.8 / 14,
    color: appTheme.textMuted,
  );

  /// Password-rule chip — Nunito Regular 12.
  static TextStyle get hintChipLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 14.4 / 12,
    color: appTheme.hintText,
  );

  /// Inline field error — Nunito Regular 14.
  static TextStyle get inlineError => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.8 / 14,
    color: const Color(0xFFF44336),
  );

  /// "Don't have an account? Sign up" — Nunito Regular 14.
  static TextStyle get authFooter => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.8 / 14,
    letterSpacing: 0.17,
    color: appTheme.textPrimary,
  );

  // --- Home screen. Measured from the Figma export; see
  // tool/figma_export/home_spec.md for the source values.

  /// Section heading ("Explore", "Recommended for you").
  static TextStyle get sectionTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 20.8 / 16,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// "Hi, Dera" — gradient filled, not flat; see [GradientText].
  static TextStyle get homeGreeting => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 27.3 / 20,
    color: appTheme.textPrimary,
  );

  /// "How are you today?"
  static TextStyle get homeGreetingSub => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w300,
    fontVariations: const [FontVariation('wght', 300)],
    height: 16.4 / 12,
    color: appTheme.textBlack,
  );

  /// "My stats" — Nunito Sans Bold 16. A heavier weight than
  /// [sectionTitle]'s 600, which is what the Profile frame specifies.
  static TextStyle get statsHeading => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.824 / 16,
    color: appTheme.textPrimary,
  );

  /// Discovery search placeholder — Nunito Regular 12.
  static TextStyle get searchHint => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.368 / 12,
    color: appTheme.navInactive,
  );

  /// What the user has typed into Discovery's field, and the line under it
  /// while the search is in flight.
  static TextStyle get searchInput =>
      searchHint.copyWith(color: appTheme.textPrimary);

  static TextStyle get searchStatus => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get searchEmptyBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.navInactive,
  );

  /// The tiny white-on-charcoal duration and rating pills over a Discovery
  /// cover — Nunito Sans SemiBold 6. Genuinely 6px in the design.
  static TextStyle get cardMeta => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 6.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 7.8 / 6,
    letterSpacing: -0.2,
    color: appTheme.onPrimary,
  );

  /// A plan row's name and its price — Nunito Medium 12.
  static TextStyle get planLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 16.368 / 12,
    color: appTheme.textPrimary,
  );

  /// "Subscribe" — Nunito Sans ExtraBold 16 on the brand fill.
  static TextStyle get subscribeLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    height: 24 / 16,
    color: appTheme.onPrimary,
  );

  /// Monthly / Annual — Nunito Bold 20.
  static TextStyle get periodLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 24 / 20,
    color: appTheme.textPrimary,
  );

  /// "Save up to #10,000" — Nunito SemiBold 10, gradient filled in the design.
  static TextStyle get periodSaving => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 12 / 10,
    color: appTheme.soothifyBlue,
  );

  /// A plan card's name — Nunito Bold 16.
  /// The Settings sub-screens — Figma `259:37589` and siblings. The heading
  /// is Nunito ExtraBold 20 centred; the body and the rows are Nunito 16, the
  /// body Medium and a row SemiBold.
  static TextStyle get settingsPageHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    height: 27.3 / 20,
    color: appTheme.textPrimary,
  );

  /// The cancellation policy's numbered headings and its effective date.
  static TextStyle get policyScreenHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 20.5 / 15,
    color: appTheme.textPrimary,
  );

  static TextStyle get policyEffectiveDate => TextStyle(
    fontFamily: fontNunito,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 17.7 / 13,
    color: appTheme.hintText,
  );

  /// A headed block on About Us — Nunito Bold 16, flush left above its
  /// paragraph.
  static TextStyle get settingsSectionHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get settingsPageBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get settingsRowLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  /// The name under the avatar on "User Profile" — Nunito Sans Bold 20.
  static TextStyle get profileName => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 24 / 20,
    color: appTheme.textPrimary,
  );

  /// The photo-source sheet's rows — Nunito Sans SemiBold 14, the chosen one
  /// in the brand blue.
  static TextStyle get photoSource => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 1,
    color: appTheme.textPrimary,
  );

  static TextStyle get photoSourceSelected =>
      photoSource.copyWith(color: appTheme.soothifyBlue);

  /// A confirmation dialog's question and the line under it.
  static TextStyle get confirmDialogTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 24.5 / 18,
    color: appTheme.textPrimary,
  );

  static TextStyle get confirmDialogBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.1 / 14,
    color: appTheme.textSecondary,
  );

  /// The "NEW" tag on Discovery's Spaces card.
  static TextStyle get newTag => TextStyle(
    fontFamily: fontNunito,
    fontSize: 11.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 1,
    color: Colors.white,
  );

  // --- The 60-second breathing minute ---
  // Figma's "Push Notification" section: `313:25770`, `313:25785`,
  // `313:25825`.

  static TextStyle get breatheHeader => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get breatheHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 17.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 23 / 17,
    color: appTheme.textPrimary,
  );

  static TextStyle get breatheBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19 / 13,
    color: appTheme.textSecondary,
  );

  static TextStyle get breatheStreak => TextStyle(
    fontFamily: fontNunito,
    fontSize: 17.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 23 / 17,
    color: appTheme.textPrimary,
  );

  /// The Community holding screen — the designer's screenshot of
  /// 2026-10-05.
  static TextStyle get comingSoonHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 26.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 33 / 26,
    color: appTheme.actionFill,
  );

  static TextStyle get comingSoonBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 23 / 16,
    color: appTheme.textPrimary,
  );

  /// A line in the session card's "what you get" list.
  ///
  /// 14, not the frame's nominal 15: this project's bundled face sets wider
  /// than Figma's, and at 15 "Flexible rescheduling up to 24 hours prior"
  /// wrapped onto a second line the design does not have.
  static TextStyle get sessionInclude => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18 / 14,
    color: appTheme.textPrimary,
  );

  // --- The trial pop-up and its payment screen ---
  // Figma `311:25655`, `311:25477` and `311:25582`, redrawn 2026-10-05.

  static TextStyle get trialTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 31.2 / 24,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get trialBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 21 / 14,
    letterSpacing: 0.3,
    color: appTheme.textPrimary,
  );

  static TextStyle get trialRestore => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20.8 / 16,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// A timeline step's day, coloured by its caller.
  static TextStyle get trialStep => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 15.6 / 12,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get trialStepBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18 / 12,
    letterSpacing: 0.3,
    color: appTheme.textPrimary.withValues(alpha: 0.88),
  );

  static TextStyle get trialSavingBadge => TextStyle(
    fontFamily: fontNunito,
    fontSize: 8.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 10.9 / 8,
    color: appTheme.textPrimary,
  );

  static TextStyle get trialPlanTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  static TextStyle get trialPlanSub => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 13.6 / 10,
    color: appTheme.onPrimary.withValues(alpha: 0.72),
  );

  static TextStyle get trialDue => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 18 / 12,
    letterSpacing: 0.3,
    color: appTheme.textPrimary,
  );

  static TextStyle get trialRenews => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 15 / 10,
    letterSpacing: 0.3,
    color: appTheme.textPrimary.withValues(alpha: 0.72),
  );

  static TextStyle get trialBenefit => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 11.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 14.3 / 11,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get trialFootnote => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 14.4 / 12,
    letterSpacing: 0.3,
    color: appTheme.textPrimary,
  );

  /// The payment screen.
  static TextStyle get paymentWordmark => TextStyle(
    fontFamily: fontPacifico,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    height: 35.1 / 20,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 20,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentBlurb => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18.2 / 14,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentSection => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentLink => TextStyle(
    fontFamily: fontNunito,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 17.7 / 13,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get paymentPlanName => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentChip => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 13.6 / 10,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentChipPlain => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentMuted => TextStyle(
    fontFamily: fontNunito,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 17.7 / 13,
    color: appTheme.textPrimary.withValues(alpha: 0.72),
  );

  static TextStyle get paymentValue => TextStyle(
    fontFamily: fontNunito,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 17.7 / 13,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentHint =>
      paymentValue.copyWith(color: appTheme.paymentHintInk);

  /// The trial credit, which the frame sets in green.
  static TextStyle get paymentCredit => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.success,
  );

  static TextStyle get paymentTotalLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    height: 20.5 / 15,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentTotalAmount => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 22.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    height: 30 / 22,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get paymentFirstCharge => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 17.7 / 13,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentFinePrint => TextStyle(
    fontFamily: fontNunito,
    fontSize: 11.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16 / 11,
    color: appTheme.textPrimary.withValues(alpha: 0.72),
  );

  static TextStyle get paymentMethodLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentWallet => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 1,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentFieldLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentApply => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 16.4 / 12,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get paymentVisa => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 11.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    height: 15 / 11,
    color: const Color(0xFF274889),
  );

  static TextStyle get paymentMastercard => TextStyle(
    fontFamily: fontNunito,
    fontSize: 9.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 12.3 / 9,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentInfoGlyph => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 9.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 1,
    color: appTheme.onPrimary,
  );

  // --- Your Subscription, Change Your Plan, Billing History ---
  // Figma `308:25746` and siblings. NunitoSans throughout, which is what the
  // redrawn set uses; the rest of Settings is Nunito.

  /// "You currently don't have an active subscription." and the other card
  /// headlines — NunitoSans ExtraBold 20.
  static TextStyle get subscriptionHeadline => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    height: 26 / 20,
    color: appTheme.textPrimary,
  );

  /// The grey paragraph under a headline.
  static TextStyle get subscriptionBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20.5 / 15,
    color: appTheme.textSecondary,
  );

  /// Status pills, the savings badge and "Current plan" — all 12 bold, each
  /// coloured by its caller.
  static TextStyle get subscriptionBadge => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 16.4 / 12,
    color: appTheme.textSecondary,
  );

  static TextStyle get subscriptionPlanName => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 24 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get subscriptionPlanPrice => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 20 / 14,
    color: appTheme.textSecondary,
  );

  /// "Payment Method", and a billing row's date.
  static TextStyle get subscriptionLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20 / 14,
    color: appTheme.textSecondary,
  );

  /// "Mastercard ending in •••••".
  static TextStyle get subscriptionValue => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 20 / 14,
    color: appTheme.textPrimary,
  );

  /// "Update", "View past receipts", "Download PDF".
  static TextStyle get subscriptionLink => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.soothifyBlue,
  );

  /// "Confirm Cancellation" — a link the design deliberately keeps quiet.
  static TextStyle get subscriptionQuietLink =>
      subscriptionLink.copyWith(color: appTheme.textSecondary);

  /// "Cancel Subscription".
  static TextStyle get subscriptionDestructive =>
      subscriptionLink.copyWith(color: appTheme.destructiveInk);

  /// "(billed as ₦150,000 once a year)".
  static TextStyle get subscriptionCadence => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18 / 13,
    color: appTheme.textSecondary,
  );

  /// The proration card's explanation.
  static TextStyle get subscriptionNotice => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20 / 14,
    color: appTheme.textSecondary,
  );

  /// A billing row's amount.
  static TextStyle get subscriptionAmount => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    height: 24 / 18,
    color: appTheme.textPrimary,
  );

  /// The Corporate form's field captions, and the line on its success card —
  /// Nunito Bold 14 over a 19.1 pitch. Figma `259:36101` / `259:36093`.
  static TextStyle get corporateLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  /// A Schedule card's title — Nunito Bold 16, measured on its own frame.
  ///
  /// It borrowed the Plans card's style until Plans was redrawn at 20 and
  /// took this with it. The two screens are not the same screen.
  static TextStyle get scheduleCardTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.824 / 16,
    color: appTheme.textPrimary,
  );

  /// A plan card's name — Nunito Bold 20.
  static TextStyle get tierName => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 27.28 / 20,
    color: appTheme.textPrimary,
  );

  /// A plan card's paragraph — Nunito 18 over a 25 pitch. Larger than most
  /// body copy in the app; the redrawn cards are built around it.
  static TextStyle get tierBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 25 / 18,
    color: appTheme.textPrimary,
  );

  /// The amount alone, painted with the brand gradient.
  static TextStyle get tierPrice => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 27.28 / 20,
    color: appTheme.textPrimary,
  );

  /// "/One time access" — grey, and two thirds the amount's size.
  static TextStyle get tierPriceTerms => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.096 / 14,
    color: appTheme.hintText,
  );

  /// A plan card's button label — Nunito Bold 16, tinted by the card.
  static TextStyle get trialButtonLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.824 / 16,
    color: appTheme.soothifyBlue,
  );

  /// A Settings row label, and the version line — Nunito SemiBold 16.
  static TextStyle get settingsRow => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 21.824 / 16,
    color: appTheme.textPrimary,
  );

  /// A notification line — the actor is bold, the rest regular. Both come
  /// from the same size so they sit on one baseline.
  ///
  /// Nunito 12/14.4, measured off `259:26851`. It shipped at NunitoSans 15,
  /// which came from an older revision of the frame.
  static TextStyle get notificationText => TextStyle(
        fontFamily: fontNunito,
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 14.4 / 12,
        color: appTheme.textPrimary,
      );

  static TextStyle get notificationActor =>
      notificationText.copyWith(
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
      );

  /// "45 minutes ago" — the frame prints it in the body ink at 64%.
  static TextStyle get notificationTime => TextStyle(
        fontFamily: fontNunito,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 12 / 10,
        color: appTheme.textPrimary.withValues(alpha: 0.64),
      );

  /// "Your Weekly Mindful Quotes", and the recommendation card's heading —
  /// the only two bold lines in the feed.
  static TextStyle get notificationDigestTitle => TextStyle(
        fontFamily: fontNunito,
        fontSize: 12.fSize,
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
        height: 14.4 / 12,
        color: appTheme.textPrimary,
      );

  /// The two-line body under either of those headings. Left-aligned in the
  /// frame, not centred.
  static TextStyle get notificationCardBody => TextStyle(
        fontFamily: fontNunito,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 12 / 10,
        color: appTheme.textPrimary,
      );

  /// A filter chip's label; [notificationChipSelected] once chosen.
  static TextStyle get notificationChip => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        color: appTheme.textPrimary,
      );

  static TextStyle get notificationChipSelected =>
      notificationChip.copyWith(color: appTheme.onPrimary);

  /// The "New" tag the What's new chip carries.
  static TextStyle get notificationChipBadge => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 9.fSize,
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
        height: 1,
        color: Colors.white,
      );

  /// The screen title, painted with the app's title gradient like the other
  /// gradient headings.
  static TextStyle get notificationTitle => TextStyle(
        fontFamily: fontNunito,
        // Nunito Bold 16, the same as every other screen's [appBarTitle].
        // It shipped at NunitoSans 20, which `259:26851` does not draw.
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
        height: 19.2 / 16,
      );

  /// The opening line on a mood recommendation — Nunito Sans Bold 18 over
  /// three lines at a 21 pitch.
  static TextStyle get moodRecommendationIntro => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 18.fSize,
        // 500, not Bold. The designer set this line lighter on 2026-10-05;
        // it had been Bold since the screen was first measured.
        fontWeight: FontWeight.w500,
        fontVariations: const [FontVariation('wght', 500)],
        height: 21 / 18,
        color: appTheme.textPrimary,
      );

  /// AI Hub — the grey caption over each readout.
  static TextStyle get aiStatLabel => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 16 / 12,
        color: appTheme.aiStatLabel,
      );

  /// AI Hub — the readout itself.
  static TextStyle get aiStatValue => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 15.fSize,
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
        height: 20 / 15,
        color: appTheme.aiStatValue,
      );

  /// "Select Environment Vibe".
  static TextStyle get aiSectionLabel => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 19 / 14,
        color: appTheme.textPrimary,
      );

  /// A segment's label; [aiSegmentSelected] once it is the chosen one.
  static TextStyle get aiSegmentLabel => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        color: appTheme.aiStatValue,
      );

  static TextStyle get aiSegmentSelected =>
      aiSegmentLabel.copyWith(color: appTheme.onPrimary);

  /// "Tap Droplet or Chat to Expand", on its pill over the scene.
  static TextStyle get aiPanelHint => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
        fontVariations: const [FontVariation('wght', 500)],
        height: 14 / 10,
        color: appTheme.onPrimary,
      );

  /// "Wellness Guide" over the expanded scene.
  static TextStyle get guideName => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
        height: 27 / 20,
        color: appTheme.onPrimary,
      );

  /// A chat bubble's text. The guide's bubbles are white with dark ink; the
  /// user's are blue with white.
  static TextStyle get guideBubble => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 15.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 21 / 15,
        color: appTheme.aiStatValue,
      );

  static TextStyle get guideBubbleOwn =>
      guideBubble.copyWith(color: appTheme.onPrimary);

  /// "Ask anything..." in the composer.
  static TextStyle get guideComposerHint => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 15.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        color: appTheme.hintText,
      );

  /// The pitch inside the guest sign-up card — Nunito Sans Bold 16, white.
  static TextStyle get signupPitch => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
        height: 22 / 16,
        color: appTheme.onPrimary,
      );

  /// "Awful" / "Awesome" under the Mood Checker slider — Nunito Sans
  /// Regular 14 in the brand blue.
  static TextStyle get moodScaleEnd => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 18.2 / 14,
        color: appTheme.moodThumb,
      );

  /// A filter sheet's heading — "Duration", "More Filters", "Style".
  /// Nunito Sans Bold 16.
  static TextStyle get filterHeading => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 20.8 / 16,
    color: appTheme.textPrimary,
  );

  /// A chip group's label on More Filters — Nunito Sans Bold 14.
  static TextStyle get filterGroupLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 18 / 14,
    color: appTheme.textPrimary,
  );

  /// A filter chip's label — Nunito Sans Regular 12.
  static TextStyle get filterChipLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 15.6 / 12,
    color: appTheme.textPrimary,
  );

  /// The same label once the chip is filled.
  static TextStyle get filterChipLabelSelected =>
      filterChipLabel.copyWith(color: appTheme.onPrimary);

  /// The "See More..." link closing a chip group — Nunito Sans Black 10.
  static TextStyle get filterSeeMore => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w900,
    fontVariations: const [FontVariation('wght', 900)],
    height: 13 / 10,
    color: appTheme.textPrimary,
  );

  /// A Style card's name — Nunito Sans Bold 14.
  static TextStyle get filterStyleTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 20 / 14,
    color: appTheme.textPrimary,
  );

  /// A Style card's description — Nunito Sans Regular 10.
  static TextStyle get filterStyleBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 13 / 10,
    color: appTheme.textPrimary,
  );

  /// A Community topic chip's label — Nunito Regular 14.
  static TextStyle get topicChip => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.8 / 14,
    color: appTheme.topicChipLabel,
  );

  /// "Chidera Dera" and "Topics" — Nunito Bold 20.
  static TextStyle get communityHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 24 / 20,
    color: appTheme.textPrimary,
  );

  /// The location line and the Topics blurb — Nunito Regular 16.
  static TextStyle get communityBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.2 / 16,
    color: appTheme.textPrimary,
  );

  /// "Schedule live sessions with experts" — Nunito Sans Bold 20.
  static TextStyle get scheduleHeading => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 20,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// A Schedule card's blurb — Nunito Regular 14, white on the gradient.
  static TextStyle get scheduleBlurb => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.096 / 14,
    color: appTheme.onPrimary,
  );

  /// A library shelf heading — Nunito Medium 16, pure black in the design.
  static TextStyle get shelfHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 21.824 / 16,
    color: appTheme.textBlack,
  );

  /// "Welcome to Soothify Community" — Nunito Sans Bold 20, brand ink.
  static TextStyle get communityWelcomeTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 27.28 / 20,
    color: appTheme.brandInk,
  );

  /// The welcome blurb — Nunito Sans SemiBold 20.
  static TextStyle get communityWelcomeBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 27.28 / 20,
    color: appTheme.textBlack,
  );

  /// A form field's label. The design sets these in Inter, which the app does
  /// not bundle; Nunito is the nearest bundled face.
  static TextStyle get formLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 16.94 / 14,
    color: appTheme.textPrimary,
  );

  /// A discussion card's title — Nunito Bold 20, white on the brand fill.
  static TextStyle get discussionTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 24 / 20,
    color: appTheme.onPrimary,
  );

  /// A discussion card's body and author — Nunito Regular 16, white.
  static TextStyle get discussionBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.2 / 16,
    color: appTheme.onPrimary,
  );

  /// A discussion card's counters and timestamp — Nunito Regular 8.
  static TextStyle get discussionMeta => TextStyle(
    fontFamily: fontNunito,
    fontSize: 8.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 9.6 / 8,
    color: appTheme.onPrimary,
  );

  /// "Load more" / "Start Discussion" — Nunito Sans Bold 16.
  static TextStyle get forumAction => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.2 / 16,
    color: appTheme.soothifyBlue,
  );

  /// A comment's author — Nunito SemiBold 16, matching the 19px line box the
  /// thread frame measures.
  static TextStyle get commentAuthor => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 19.2 / 16,
    color: appTheme.textPrimary,
  );

  /// A comment's body — Nunito Regular 16, three lines to the frame's 57px.
  static TextStyle get commentBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.2 / 16,
    color: appTheme.textPrimary,
  );

  /// A comment's timestamp — Nunito Regular 8, as on the forum cards.
  static TextStyle get commentMeta => TextStyle(
    fontFamily: fontNunito,
    fontSize: 8.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 9.6 / 8,
    color: appTheme.textSecondary,
  );

  /// The "Reply" link — Nunito SemiBold 12 in the brand blue.
  static TextStyle get replyLink => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.soothifyBlue,
  );

  /// The Sleep Stories card title — Nunito Sans Bold 20.
  static TextStyle get featureTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  /// Its supporting line — Nunito Sans Regular 10.
  static TextStyle get featureBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textPrimary,
  );

  /// The sessions promo title — Nunito Sans Bold 16.
  static TextStyle get promoTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 20.8 / 16,
    color: appTheme.textPrimary,
  );

  /// Its supporting line — Nunito Sans Regular 14.
  static TextStyle get promoBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18.2 / 14,
    color: appTheme.textPrimary,
  );

  /// A wellness questionnaire's prompt — Nunito Sans Bold 20, gradient
  /// filled in the design.
  static TextStyle get kycQuestion => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 20,
    color: appTheme.textPrimary,
  );

  /// The matching interstitial's supporting line — Nunito Sans SemiBold 10.
  static TextStyle get matchingBlurb => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 13 / 10,
    color: appTheme.textPrimary,
  );

  /// The communication-method blurb — Nunito Sans Light 10.
  static TextStyle get methodBlurb => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w300,
    fontVariations: const [FontVariation('wght', 300)],
    height: 13 / 10,
    color: appTheme.textPrimary,
  );

  /// The coach's name and the call timer — Nunito Bold 20.
  static TextStyle get callName => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 20,
    color: appTheme.textPrimary,
  );

  /// "Awesome! You matched with" and the section headings on the coach
  /// profile — Nunito Sans Bold 20.
  static TextStyle get matchedLead => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 20,
    color: appTheme.textPrimary,
  );

  /// The coach's name — Nunito Black 20, gradient filled.
  static TextStyle get coachName => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w900,
    fontVariations: const [FontVariation('wght', 900)],
    height: 26 / 20,
    color: appTheme.textPrimary,
  );

  /// "98% Match" — Nunito Sans Bold 10, reversed on the dark badge.
  static TextStyle get matchBadge => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.onPrimary,
  );

  /// Body copy on the coach profile — Nunito Regular 14.
  static TextStyle get coachBlurb => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18 / 14,
    color: appTheme.textPrimary,
  );

  /// A "Book a licensed expert" card's title — Nunito Bold 16 on `#263238`,
  /// per `259:31488`.
  /// The Cancellation Policy screen's body — Nunito Sans Light 14 on
  /// `#263238`, per `280:26738`. Light, not the panel's regular weight.
  static TextStyle get policyScreenBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w300,
    fontVariations: const [FontVariation('wght', 300)],
    height: 18.2 / 14,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// The Care Guarantee panel — Figma `280:26699`. Nunito Sans Bold 12 in
  /// the success ink.
  static TextStyle get careGuaranteeTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 16.4 / 12,
    color: appTheme.successInk,
  );

  static TextStyle get careGuaranteeItem => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18 / 13,
    color: appTheme.textPrimary.withValues(alpha: 0.88),
  );

  /// The checkout summary's two rows — the label is grey, everything the
  /// money touches is bold ink.
  static TextStyle get summaryLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.1 / 14,
    // #999999 in the frame — the same grey the hints use.
    color: appTheme.hintText,
  );

  static TextStyle get summaryValue => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  /// "Spaces Around Me" — Figma `282:25161`.
  static TextStyle get spaceSearchHint => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.hintText,
  );

  static TextStyle get spaceSearch =>
      spaceSearchHint.copyWith(color: appTheme.textPrimary);

  static TextStyle get spaceChip => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  static TextStyle get spaceChipSelected =>
      spaceChip.copyWith(color: appTheme.onPrimary);

  /// The List/Map pair — Nunito SemiBold 12, the unselected one grey.
  static TextStyle get spaceView => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: const [FontVariation('wght', 600)],
    height: 16.4 / 12,
    color: appTheme.spaceTagInk,
  );

  static TextStyle get spaceViewSelected =>
      spaceView.copyWith(color: appTheme.textPrimary);

  static TextStyle get spaceName => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  static TextStyle get spaceArea => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 13.6 / 10,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get spaceTag => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 13.6 / 10,
    color: appTheme.spaceTagInk,
  );

  static TextStyle get spaceDistance =>
      spaceTag.copyWith(color: appTheme.soothifyBlue);

  static TextStyle get spaceDirections => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 16.4 / 12,
    color: appTheme.soothifyBlue,
  );

  /// The Discover entry into "Spaces Around Me" — white on the blue card, so
  /// these two carry their own colours rather than taking a theme token.
  static TextStyle get spacesEntryTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.8 / 16,
    color: Colors.white,
  );

  static TextStyle get spacesEntrySubtitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: Colors.white.withValues(alpha: 0.88),
  );

  static TextStyle get spaceMapHint => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  /// The studio profile — `282:25339`.
  static TextStyle get studioCounter => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 19.1 / 14,
    color: appTheme.onPrimary,
  );

  static TextStyle get studioLocation => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get studioAbout => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.1 / 14,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get studioSecondaryAction => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    color: appTheme.actionFill,
  );

  /// The second half of the teaser, which the frame colours `#2F6FED` — the
  /// run that makes it a link.
  static TextStyle get studioTeaserLink =>
      studioTeaser.copyWith(color: appTheme.soothifyBlue);

  static TextStyle get studioTeaser => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  /// Care Support — Figma `280:26747`.
  static TextStyle get careSupportHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get careSupportNote => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get careConcern => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.8 / 14,
    color: appTheme.textPrimary.withValues(alpha: 0.72),
  );

  /// "(Please specify)" — `#999999`, lighter than the choice it follows.
  static TextStyle get careConcernHint =>
      careConcern.copyWith(color: appTheme.hintText);

  /// Nunito Medium 12 at 64% — quieter than the note above the options.
  static TextStyle get careSupportFootnote => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 16.4 / 12,
    color: appTheme.textPrimary.withValues(alpha: 0.64),
  );

  /// The sent state — `280:26775`.
  static TextStyle get careSentTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get careSentBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertOfferTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  /// The same card's "One on one session with a professional" — Nunito
  /// Regular 14. Same colour as the title in the frame, not a muted subtitle.
  static TextStyle get expertOfferBlurb => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  /// "Because you like" / "Other Instructors Matches" — Nunito SemiBold 14.
  static TextStyle get coachSection => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// "Signature quote" / "Expertise in" — Nunito SemiBold 16.
  static TextStyle get coachHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// An interest chip — Nunito Sans Regular 10.
  static TextStyle get coachChip => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textPrimary,
  );

  /// The calendar sheet's month, weekday row and day numbers.
  static TextStyle get calendarMonth => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get calendarWeekday => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textSecondary,
  );

  static TextStyle get calendarDay => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    color: appTheme.textPrimary,
  );

  /// A See All grid card's title — Nunito Sans Bold 14.
  static TextStyle get gridTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  /// Its practitioner — Nunito Sans SemiBold 10.
  static TextStyle get gridAuthor => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// The splash's breathing prompts — white on the brand gradient.
  /// "Inhale Deeply" / "Exhale Slowly" on the splash — the designer's panel
  /// of 2026-10-07: Nunito Sans Bold 24 on a 24 line, no letter spacing. It
  /// was Light 28 tracked out to 1.2, which was this app's reading of the
  /// frame rather than the frame's own values.
  static TextStyle get breathPrompt => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 24 / 24,
    color: appTheme.onPrimary,
  );

  /// A media item's title on its detail screen — Nunito SemiBold 20.
  static TextStyle get mediaTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// Its rating, duration and description — Nunito Regular 14.
  static TextStyle get mediaBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20 / 14,
    color: appTheme.textPrimary,
  );

  /// The instructor card's caption — Nunito Regular 11.
  static TextStyle get mediaCaption => TextStyle(
    fontFamily: fontNunito,
    fontSize: 11.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.navInactive,
  );

  /// The instructor's name — Nunito SemiBold 14.
  static TextStyle get mediaInstructor => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// The player's elapsed/total readout — Nunito Regular 10, white.
  static TextStyle get playerTime => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.onPrimary,
  );

  /// "Add Note" — Nunito Sans ExtraBold 14, gradient filled.
  static TextStyle get addNote => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    color: appTheme.textPrimary,
  );

  /// The two facts at the foot — Nunito Sans Regular 16.
  static TextStyle get mediaFact => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 21 / 16,
    color: appTheme.textPrimary,
  );

  /// Profile segmented control — Nunito Medium 10.
  static TextStyle get segmentLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 13.64 / 10,
    color: appTheme.textPrimary,
  );

  /// Profile stat caption and its value — both Nunito Sans Bold 10, white on
  /// the gradient card.
  static TextStyle get statLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 13.64 / 10,
    color: appTheme.onPrimary,
  );

  /// The white pill inside the stats card — Nunito Sans ExtraBold 14. The
  /// design's line height is *below* the font size (12 on 14), which crops
  /// the box; height is left unset so the label is not clipped.
  static TextStyle get statsActionLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    color: appTheme.actionFill,
  );

  /// Bottom-nav label. The odd size is the design's own — 10.88, not 11.
  static TextStyle get navLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.88.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 14.8 / 10.88,
    color: appTheme.navInactive,
  );

  /// Mood Checker card — white on the card's own artwork.
  static TextStyle get homeCardTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.onPrimary,
  );

  static TextStyle get homeCardBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 11.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.onPrimary,
  );

  /// Explore tile caption.
  /// An Explore tile's caption. The explicit line height is what lets the
  /// row reserve exactly two lines for every tile, so a caption that wraps
  /// does not make its own tile taller than the two beside it.
  static TextStyle get exploreLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: exploreLabelLine / 10,
    color: appTheme.textPrimary,
  );

  /// One caption line, in logical pixels before scaling.
  static const double exploreLabelLine = 14;

  /// Content card: category line, title, then author.
  static TextStyle get itemCategory => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  static TextStyle get itemTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  static TextStyle get itemAuthor => itemCategory;

  /// The white pill naming a category, over the cover art.
  static TextStyle get pillLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 8.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// Duration and rating, on the dark pills.
  static TextStyle get pillLabelOnDark => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 6.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.onPrimary,
  );

  /// "Popular Content" — the one heading in Nunito rather than Nunito Sans.
  static TextStyle get popularHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    color: appTheme.textBlack,
  );

  static TextStyle get seeAll => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.soothifyBlue,
  );

  /// "Nice job today, Rita." — Nunito Sans Bold 20, centred.
  static TextStyle get recordCelebration => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 27.3 / 20,
    color: appTheme.textPrimary,
  );

  /// The line under it — Nunito Sans Regular 15, centred.
  static TextStyle get recordCelebrationBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20.5 / 15,
    color: appTheme.textPrimary,
  );

  /// Today's weekday label in the streak strip — larger than the rest.
  static TextStyle get streakDayToday => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 18.2 / 14,
    letterSpacing: -0.2,
    color: appTheme.soothifyBlue,
  );

  /// Empty-state heading ("No entries yet").
  static TextStyle get emptyStateTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 27.3 / 20,
    color: appTheme.textPrimary,
  );

  /// The paragraph beneath it.
  static TextStyle get emptyStateBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  /// Journal composer: the date and time in the header bar.
  static TextStyle get journalDate => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// The prompt itself, and the body being written.
  static TextStyle get journalPrompt => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 1.4,
    color: appTheme.textSecondary,
  );

  /// "Change prompt" — Nunito Sans Light 10.
  static TextStyle get journalChangePrompt => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w300,
    fontVariations: const [FontVariation('wght', 300)],
    height: 13.6 / 10,
    color: appTheme.textPrimary,
  );

  /// Weekday label above a day marker — Nunito Sans SemiBold 10, brand blue.
  static TextStyle get weekdayLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 1.3,
    letterSpacing: -0.2,
    color: appTheme.soothifyBlue,
  );

  /// Date beneath a day marker — same size, ink coloured.
  static TextStyle get weekdayDate => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 1.3,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// Mood-record headline — Nunito Sans Bold 20.
  static TextStyle get recordHeadline => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  /// "July 2024" — Nunito Sans Regular 14.
  static TextStyle get recordMonth => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 1.3,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// Caption inside the selected-day card — Nunito Sans Bold 14.
  static TextStyle get recordCardCaption => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  /// Auth wordmark — Pacifico 32 on the gradient header.
  static TextStyle get authWordmark => TextStyle(
    fontFamily: fontPacifico,
    fontSize: 32.fSize,
    color: appTheme.onPrimary,
  );

  /// Active auth tab — Nunito Sans Bold 32.
  static TextStyle get authTabActive => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 32.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.onPrimary,
  );

  /// Inactive auth tab — Nunito Sans Light 20.
  static TextStyle get authTabInactive => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w300,
    fontVariations: const [FontVariation('wght', 300)],
    color: appTheme.onPrimary,
  );

  /// Field caption above the value — Nunito Sans Regular 14.
  static TextStyle get fieldLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textPrimary,
  );

  /// Field value — Nunito Sans SemiBold 20.
  static TextStyle get fieldValue => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.textPrimary,
  );

  /// Auth CTA label — Nunito Sans SemiBold 20.
  static TextStyle get authButtonLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    color: appTheme.onPrimary,
  );

  /// "Forgot Password?" — Nunito Sans Regular 14.
  static TextStyle get authFootnote => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textPrimary,
  );

  /// Option row label — Nunito Regular 14 at 72% ink.
  static TextStyle get optionLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 1.2,
    color: appTheme.textMuted,
  );

  /// Full-width button label — Nunito Sans ExtraBold 18.
  static TextStyle get buttonLabel => buttonLabelFor(appTheme);

  /// Nunito Sans ExtraBold **16**, which is what every current frame sets a
  /// button label at — `259:59*` and `280:*` alike. It was 18, carried over
  /// from the previous file ("Apply", "Book session"), which ran every newer
  /// screen's action two points large.
  static TextStyle buttonLabelFor(PrimaryColors c) => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    color: c.onPrimary,
  );

  // --- Personal Journal (259:36946 empty, 259:36965 populated) ---

  /// The two-way tab over the list. Bold 16; the chosen half is painted on
  /// the navy gradient, so it takes [onPrimary] rather than a second style.
  /// The Journal's two-way tab.
  ///
  /// 14, not the frame's 16. At 16 the bundled NunitoSans set "Expert
  /// Recommendation" wider than its half of the control and clipped it to
  /// "Expert Recommendatio" — the same face measured wider than the design's
  /// instance on the community welcome.
  static TextStyle get journalTab => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get journalTabSelected =>
      journalTab.copyWith(color: appTheme.onPrimary);

  /// An entry card: the date line, the heading, then the note itself.
  static TextStyle get journalEntryDate => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textSecondary,
  );

  static TextStyle get journalEntryTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get journalEntryBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16 / 14,
    color: appTheme.textSecondary,
  );

  // --- Expert Recommendation tab (259:60842) ---

  static TextStyle get expertName => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertMeta => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textSecondary,
  );

  static TextStyle get expertNoteLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertNoteBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19 / 14,
    color: appTheme.textPrimary,
  );

  /// The blue "Video" kicker over a recommended piece of content.
  static TextStyle get expertContentKind => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get expertContentTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  // --- Article reader (259:58647 Pilates & Core, 259:58687 Stretch) ---

  /// Two lines at a 32 pitch, ending clear of the rating.
  static TextStyle get articleTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 32 / 24,
    color: appTheme.textPrimary,
  );

  static TextStyle get articleRating => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.textPrimary,
  );

  /// Body copy — seven lines at a 19 pitch in the frame.
  static TextStyle get articleBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19 / 16,
    color: appTheme.textPrimary,
  );

  /// The blue runs inside the closing call to action.
  static TextStyle get articleLink =>
      articleBody.copyWith(color: appTheme.soothifyBlue);

  // --- Booking payment (259:58862 therapist, 259:58919 / 259:58941) ---

  /// "Ready for your session with ..." — painted on [titleGradient], which is
  /// what the sampled #234D9F -> #1F3A6E run turned out to be.
  /// 19, not the frame's nominal 24. "Ready for your session with Baraqhat"
  /// fills the 342 content width exactly in the designer's screenshot, on one
  /// line; this project's bundled face sets wider, so it only fits at 19.
  static TextStyle get paymentHeadline => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 19.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 25 / 19,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentSubtitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18.5 / 15,
    color: appTheme.textPrimary,
  );

  /// The booking confirmation's three lines, painted on [titleGradient].
  static TextStyle get bookedMessage => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 19.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 19,
    color: appTheme.textPrimary,
  );

  /// The day and time under it.
  static TextStyle get bookedWhen => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: const [FontVariation('wght', 600)],
    height: 19 / 14,
    color: appTheme.textPrimary.withValues(alpha: 0.72),
  );

  /// "Redirecting you back to home in 3 sec" — faint, near the bottom.
  static TextStyle get redirectNote => TextStyle(
    fontFamily: fontNunito,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18 / 13,
    color: appTheme.textPrimary.withValues(alpha: 0.45),
  );

  /// "Monday, 28 September at 5:00pm" under the payment screen's subtitle.
  static TextStyle get paymentWhen => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: const [FontVariation('wght', 600)],
    height: 19 / 14,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get planOptionTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 17.fSize,
    height: 20 / 17,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get planOptionPrice => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  /// "/50-minute session" — the grey run after the figure.
  static TextStyle get planOptionUnit => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    height: 24 / 14,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.hintText,
  );

  static TextStyle get policyTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get policyBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16 / 13,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get policyLink => policyBody.copyWith(
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    decoration: TextDecoration.underline,
    decorationColor: appTheme.soothifyBlue,
  );

  /// The one line inside the payment-success card.
  static TextStyle get paymentSuccess => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  // --- Become an Expert (259:59132 intro, 259:59145 onward the form) ---

  /// "Join the Soothify Expert Network" — painted on the intro's own
  /// #2F6FED -> #274889 run, which is steeper than the app's titleGradient.
  static TextStyle get expertIntroTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 32.7 / 24,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertIntroBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  /// A form question. The frame sets two of the seven at 700 and the rest at
  /// 600 — an oversight, not a distinction; all are drawn at 600 here.
  static TextStyle get expertFormLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 20.8 / 16,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// "Add file" — the small blue label on the upload chip.
  static TextStyle get expertAddFile => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 15.6 / 12,
    letterSpacing: -0.2,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get expertSubmittedTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertSubmittedBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  // --- Expert Recommendation, the Journal's second tab (259:60761) ---

  /// "Recent Live Sessions" / "Earlier Sessions".
  static TextStyle get expertGroupHeading => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 20.8 / 16,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  /// The red "New" pill on an unread session.
  static TextStyle get expertNewBadge => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 13.6 / 10,
    color: appTheme.unreadDot,
  );

  /// The unread count sitting on the tab itself.
  static TextStyle get expertTabCount => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 16.4 / 12,
    color: appTheme.onPrimary,
  );

  /// A session card: the expert, then the service and the date beneath.
  static TextStyle get sessionCardName => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  static TextStyle get sessionCardMeta => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  /// The note the expert left, inside its pale panel.
  static TextStyle get sessionCardNote => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 13.6 / 10,
    color: appTheme.textPrimary.withValues(alpha: 0.88),
  );

  /// "Watch video" / "Read Article" / "Listen".
  static TextStyle get sessionCardAction => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  // --- Expert role (259:59239 dashboard, and the row of frames beside it) ---

  /// "Welcome back," above the expert's name.
  static TextStyle get expertGreeting => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w300,
    fontVariations: const [FontVariation('wght', 300)],
    height: 16.4 / 12,
    color: appTheme.textBlack,
  );

  /// The name itself, painted on the expert intro's #2F6FED -> #274889 run.
  static TextStyle get expertName2 => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 27.3 / 20,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertGreetingSub => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textBlack,
  );

  /// A section heading — "Upcoming Sessions", "Quick Actions".
  static TextStyle get expertSection => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 20.8 / 16,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertSeeAll => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 18.2 / 14,
    letterSpacing: -0.2,
    color: appTheme.soothifyBlue,
  );

  /// A session card: the client, then what and when, then its action chip.
  static TextStyle get expertCardName => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 18.2 / 14,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertCardMeta => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 15.6 / 12,
    letterSpacing: -0.2,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get expertCardAction => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 15.6 / 12,
    letterSpacing: -0.2,
    color: appTheme.soothifyBlue,
  );

  /// The earnings card on the dashboard, on the brand gradient.
  static TextStyle get expertEarningsCaption => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.onPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get expertEarningsAmount => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 32 / 24,
    color: appTheme.onPrimary,
  );

  /// A Quick Action tile.
  static TextStyle get expertActionTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 18.2 / 14,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertActionBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 15.6 / 12,
    letterSpacing: -0.2,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  /// The Earnings screen's own figures and captions.
  static TextStyle get expertBalanceAmount => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 32 / 24,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertBalanceCaption => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  /// A "Next automatic payout" / "Payout method" row.
  static TextStyle get expertRowLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 20.8 / 16,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertPayoutAmount => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 20.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertPayoutDate => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20.8 / 16,
    color: appTheme.textPrimary,
  );

  /// The intro line under an expert screen's title.
  static TextStyle get expertBlurb => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 22 / 16,
    color: appTheme.textPrimary,
  );

  /// An availability row: the weekday, its date, and the hours.
  static TextStyle get expertSlotDay => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 20.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get expertSlotDetail => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20.8 / 16,
    color: appTheme.textPrimary,
  );

  /// A session-notes mood chip — "Good progress", "Steady", "Needs
  /// follow-up".
  static TextStyle get expertNoteChip => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 13.6 / 10,
    color: appTheme.textPrimary,
  );

  // --- Payouts (259:59559 withdrawal, 259:59463 method) ---

  /// The big centred figure on the withdrawal screen.
  static TextStyle get withdrawAmount => TextStyle(
    fontFamily: fontNunito,
    fontSize: 32.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 43.6 / 32,
    color: appTheme.textPrimary,
  );

  /// The blue line in the pill beneath it.
  static TextStyle get withdrawPrompt => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 19.1 / 14,
    color: appTheme.soothifyBlue,
  );

  /// A compact destination tile.
  static TextStyle get destinationTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 13.6 / 10,
    color: appTheme.textPrimary,
  );

  static TextStyle get destinationSubtitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 8.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 10.9 / 8,
    color: appTheme.textPrimary,
  );

  /// A full payout-method card.
  static TextStyle get payoutMethodTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get payoutMethodBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  /// The Paystack assurance panel, and its wordmark.
  static TextStyle get payoutAssurance => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 16.4 / 12,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get payoutProcessor => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w900,
    fontVariations: const [FontVariation('wght', 900)],
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  // --- Subscription pop-up (259:59011 trial, 259:58598 discounted year) ---

  static TextStyle get restorePurchase => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20.8 / 16,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get offerTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 20,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get offerBlurb => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 21 / 14,
    letterSpacing: 0.3,
    color: appTheme.textPrimary,
  );

  /// The label on the pop-up's ghost action.
  static TextStyle get offerAction => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    color: appTheme.soothifyBlue,
  );

  /// A billing-period card.
  static TextStyle get offerCardTitle => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.1 / 14,
    color: appTheme.textPrimary,
  );

  static TextStyle get offerCardNote => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 13.6 / 10,
    color: appTheme.textPrimary,
  );

  /// The Feature / Free / Premium header.
  static TextStyle get offerColumn => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21 / 14,
    letterSpacing: 0.3,
    color: appTheme.textPrimary,
  );

  static TextStyle get offerFeature => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 11.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 14.3 / 11,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  // --- Availability editor (259:60077, 259:60133) ---

  /// A wheel row. The frame dims every row but the middle one.
  static TextStyle get slotWheel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 32.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 48 / 32,
    color: appTheme.textPrimary.withValues(alpha: 0.35),
  );

  static TextStyle get slotWheelFocused =>
      slotWheel.copyWith(color: appTheme.textPrimary);

  static TextStyle get slotRepeat => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  /// The single capital inside a day circle. The frame sets these in
  /// Poppins, which the app does not bundle.
  static TextStyle get slotDayLetter => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 15 / 10,
    color: appTheme.textPrimary,
  );

  // --- Joining a session (259:59996) ---

  /// The client joining screen — Figma `280:26643`.
  static TextStyle get clientJoiningLead => TextStyle(
    fontFamily: fontNunito,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 24.5 / 18,
    color: appTheme.textPrimary,
  );

  /// "Expert" / "Session Time" and the date beneath — Nunito Sans 12 at 80%.
  static TextStyle get sessionFieldLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16 / 12,
    letterSpacing: -0.2,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get sessionFieldValue => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 17.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: const [FontVariation('wght', 600)],
    height: 22 / 17,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextStyle get callControlLabel => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  static TextStyle get joiningHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  /// The running time under the name on a call.
  static TextStyle get callClock => TextStyle(
    fontFamily: fontNunito,
    fontSize: 22.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 30 / 22,
    color: appTheme.textPrimary,
  );

  /// "Set Daily Pilates & Core Reminder" on the start screen.
  static TextStyle get dailyReminderHeading => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 19.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 26 / 19,
    color: appTheme.textPrimary,
  );

  static TextStyle get dailyReminderBlurb => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 22 / 15,
    color: appTheme.textPrimary,
  );

  /// "Morning" / "Afternoon" / "Evening".
  static TextStyle get dailyWhenLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 25 / 18,
    color: appTheme.actionFill,
  );

  /// "Update your Account Details" — the lead on the Update Account screen.
  static TextStyle get updateAccountLead => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 17.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 24 / 17,
    color: appTheme.textPrimary,
  );

  /// "Delete your account?" — the question the screen opens with.
  static TextStyle get deleteAccountLead => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 25 / 18,
    color: appTheme.textPrimary,
  );

  /// What deleting costs, under it.
  static TextStyle get deleteAccountBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 24 / 16,
    color: appTheme.textPrimary,
  );

  // --- "Need gentle support?" and its sheet ---

  /// The pill above the call.
  static TextStyle get supportPill => TextStyle(
    fontFamily: fontNunito,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 20 / 15,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get supportHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 27 / 20,
    color: appTheme.textPrimary,
  );

  static TextStyle get supportBlurb => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 20 / 14,
    color: appTheme.textPrimary.withValues(alpha: 0.72),
  );

  /// 13, not 14: the longest two reasons fill the row in the design and this
  /// project's bundled face sets wider, which broke both onto a second line.
  static TextStyle get supportReason => TextStyle(
    fontFamily: fontNunito,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19 / 13,
    color: appTheme.textPrimary,
  );

  static TextStyle get supportFootnote => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 17 / 12,
    color: appTheme.textPrimary.withValues(alpha: 0.6),
  );

  /// "Joining Call" on the client's side, which the redraw set larger than
  /// the practitioner's. Its own style so bumping one does not move the other.
  static TextStyle get clientJoiningHeading => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 27 / 20,
    color: appTheme.textPrimary,
  );

  /// The Care Guarantee as the client's joining screen states it on arrival —
  /// centred and grey, under "Joining Call".
  static TextStyle get joiningGuarantee => TextStyle(
    fontFamily: fontNunito,
    fontSize: 13.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 18 / 13,
    color: appTheme.textPrimary.withValues(alpha: 0.72),
  );

  /// The green panel's heading and body on the client's joining screen. Set
  /// apart from [careGuaranteeTitle] and [careGuaranteeItem], which the Care
  /// Guarantee screen draws at its own, much smaller, sizes.
  static TextStyle get safeSpaceTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 15.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 20.5 / 15,
    color: appTheme.successInk,
  );

  static TextStyle get safeSpaceBody => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.5.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 17.5 / 12.5,
    color: appTheme.textPrimary.withValues(alpha: 0.72),
  );

  static TextStyle get joiningBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 19.1 / 14,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get joiningCaption => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 13 / 10,
    color: appTheme.textPrimary,
  );

  static TextStyle get joiningValue => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 16 / 12,
    color: appTheme.textPrimary,
  );

  /// The green hint panel. Its own deep green, not the app's success token —
  /// that one is the disc fill, and this is type on a wash of it.
  static TextStyle get joiningHint => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 16.4 / 12,
    color: appTheme.successInk,
  );

  static TextStyle get joiningControl => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.4 / 12,
    color: appTheme.textPrimary,
  );

  /// A booking notification row — Figma `259:61271`.
  static TextStyle get notificationBookingKind => TextStyle(
    fontFamily: fontNunito,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 14.4 / 12,
    color: appTheme.textPrimary,
  );

  /// The discipline inside a booking line — the same ink at Bold, per
  /// `259:61271`.
  static TextStyle get notificationBookingEmphasis =>
      notificationBookingBody.copyWith(
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
      );

  static TextStyle get notificationBookingBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 12 / 10,
    color: appTheme.textPrimary,
  );

  /// The KYC intro's paragraph, and the "pick as many" line under a
  /// multi-select question — Nunito 400 16 in plain #323233 at 90%.
  static TextStyle get kycIntroBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 24 / 16,
    letterSpacing: 0.3,
    color: appTheme.textSubtitle,
  );

  /// The line under the matching bar — Nunito Sans SemiBold 10, centred.
  static TextStyle get matchingCaption => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 13 / 10,
    letterSpacing: -0.2,
    color: appTheme.textPrimary,
  );

  static TextTheme textThemeFor(PrimaryColors c) => TextTheme(
    displaySmall: TextStyle(
      fontFamily: fontNunitoSans,
      fontSize: 32.fSize,
      fontWeight: FontWeight.w700,
      fontVariations: _bold,
      color: c.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontNunitoSans,
      fontSize: 26.fSize,
      fontWeight: FontWeight.w700,
      fontVariations: _bold,
      color: c.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontNunitoSans,
      fontSize: 20.fSize,
      fontWeight: FontWeight.w700,
      fontVariations: _bold,
      color: c.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontNunito,
      fontSize: 18.fSize,
      fontWeight: FontWeight.w700,
      fontVariations: _bold,
      color: c.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontNunito,
      fontSize: 16.fSize,
      fontWeight: FontWeight.w600,
      fontVariations: _semiBold,
      color: c.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontNunitoSans,
      fontSize: 16.fSize,
      fontWeight: FontWeight.w400,
      fontVariations: _regular,
      color: c.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontNunitoSans,
      fontSize: 14.fSize,
      fontWeight: FontWeight.w400,
      fontVariations: _regular,
      color: c.textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontNunitoSans,
      fontSize: 12.fSize,
      fontWeight: FontWeight.w400,
      fontVariations: _regular,
      color: c.textSecondary,
    ),
    labelLarge: buttonLabelFor(c),
  );
}
