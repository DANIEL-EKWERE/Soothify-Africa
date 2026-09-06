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
