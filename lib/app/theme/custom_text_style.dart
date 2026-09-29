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
  static TextStyle get tierName => TextStyle(
    fontFamily: fontNunito,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 21.824 / 16,
    color: appTheme.textPrimary,
  );

  /// A plan card's selling points — Nunito SemiBold 20. Genuinely larger than
  /// the card's own title, which is the design's choice, not a transcription
  /// slip.
  static TextStyle get tierBody => TextStyle(
    fontFamily: fontNunito,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: _semiBold,
    height: 27.28 / 20,
    color: appTheme.textPrimary,
  );

  /// A plan card's price line — Nunito Bold 14.
  static TextStyle get tierPrice => TextStyle(
    fontFamily: fontNunito,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 19.096 / 14,
    color: appTheme.textPrimary,
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
  static TextStyle get notificationText => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 15.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 20 / 15,
        color: appTheme.textPrimary,
      );

  static TextStyle get notificationActor =>
      notificationText.copyWith(
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
      );

  /// "45 minutes ago". Dark in this frame, not the grey the carded variant
  /// uses.
  static TextStyle get notificationTime => TextStyle(
        fontFamily: fontNunitoSans,
        // 11.5 measured: "1 day ago" fills 42.5 in the frame.
        fontSize: 11.5.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 16 / 11.5,
        color: appTheme.textPrimary,
      );

  /// "Reminder" on its card.
  static TextStyle get notificationCardTitle => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 17.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 23 / 17,
        color: appTheme.textPrimary,
      );

  /// "Your Weekly Mindful Quotes".
  static TextStyle get notificationDigestTitle => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 18.fSize,
        fontWeight: FontWeight.w400,
        fontVariations: _regular,
        height: 25 / 18,
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

  /// The screen title, painted with the app's title gradient like the other
  /// gradient headings.
  static TextStyle get notificationTitle => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
        height: 27 / 20,
      );

  /// The opening line on a mood recommendation — Nunito Sans Bold 18 over
  /// three lines at a 21 pitch.
  static TextStyle get moodRecommendationIntro => TextStyle(
        fontFamily: fontNunitoSans,
        fontSize: 18.fSize,
        fontWeight: FontWeight.w700,
        fontVariations: _bold,
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
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 16.4 / 12,
    color: appTheme.successInk,
  );

  static TextStyle get careGuaranteeItem => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 13.6 / 10,
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
  static TextStyle get breathPrompt => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 28.fSize,
    fontWeight: FontWeight.w300,
    fontVariations: const [FontVariation('wght', 300)],
    letterSpacing: 1.2,
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
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    color: appTheme.onPrimary,
  );

  /// Explore tile caption.
  static TextStyle get exploreLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

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

  static TextStyle buttonLabelFor(PrimaryColors c) => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 18.fSize,
    fontWeight: FontWeight.w800,
    fontVariations: const [FontVariation('wght', 800)],
    color: c.onPrimary,
  );

  // --- Personal Journal (259:36946 empty, 259:36965 populated) ---

  /// The two-way tab over the list. Bold 16; the chosen half is painted on
  /// the navy gradient, so it takes [onPrimary] rather than a second style.
  static TextStyle get journalTab => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
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
  static TextStyle get paymentHeadline => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    height: 26 / 24,
    color: appTheme.textPrimary,
  );

  static TextStyle get paymentSubtitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 21 / 16,
    color: appTheme.textPrimary,
  );

  static TextStyle get planOptionTitle => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  static TextStyle get planOptionPrice => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    color: appTheme.textPrimary,
  );

  /// "/50-minute session" — the grey run after the figure.
  static TextStyle get planOptionUnit => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 16.fSize,
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
    height: 14.5 / 13,
    color: appTheme.soothifyBlue,
  );

  static TextStyle get policyLink => policyBody.copyWith(
    fontWeight: FontWeight.w700,
    fontVariations: _bold,
    decoration: TextDecoration.underline,
    decorationColor: appTheme.soothifyBlue,
  );

  /// The centred line under "Proceed to Payment" on the two track frames.
  static TextStyle get paymentFootnote => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 16.5 / 14,
    color: appTheme.textPrimary,
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
    fontSize: 18.fSize,
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
    fontSize: 16.fSize,
    fontWeight: FontWeight.w500,
    fontVariations: const [FontVariation('wght', 500)],
    height: 21.8 / 16,
    color: appTheme.textPrimary,
  );

  /// "Expert" / "Session Time" and the date beneath — Nunito Sans 10 at 80%.
  static TextStyle get sessionFieldLabel => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontVariations: _regular,
    height: 13 / 10,
    letterSpacing: -0.2,
    color: appTheme.textPrimary.withValues(alpha: 0.8),
  );

  static TextStyle get sessionFieldValue => TextStyle(
    fontFamily: fontNunitoSans,
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontVariations: const [FontVariation('wght', 600)],
    height: 15.6 / 12,
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
