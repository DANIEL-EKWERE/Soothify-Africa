import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import 'custom_text_style.dart';

/// The palette for the brightness currently on screen.
///
/// Screens read colours through this rather than through [Theme.of], matching
/// the convention the codebase already uses. It is kept in sync with the
/// active [ThemeData] by [PrimaryColors.syncFrom], called from the app
/// builder — so it follows a manual theme switch and the system setting alike.
PrimaryColors get appTheme => PrimaryColors.active;

/// Light [ThemeData]. Passed to `theme:`.
ThemeData get theme => ThemeHelper.lightTheme;

/// Dark [ThemeData]. Passed to `darkTheme:`.
ThemeData get darkTheme => ThemeHelper.darkTheme;

/// Every colour the app uses, in one place per brightness.
///
/// The Figma file defines no variables, so these were read from the designs.
/// Dark values come from the charcoal "A" variant of the file's
/// "Which your preferred dark mode?" A/B pair; the blue "B" variant was
/// rejected.
@immutable
class PrimaryColors {
  const PrimaryColors({
    required this.brightness,
    required this.brandLight,
    required this.brandDeep,
    required this.brandInk,
    required this.primary,
    required this.soothifyBlue,
    required this.actionFill,
    required this.actionFillDisabled,
    required this.authAccent,
    required this.fieldUnderline,
    required this.fieldFill,
    required this.authHeading,
    required this.hintChip,
    required this.hintText,
    required this.progressTrack,
    required this.dotInactive,
    required this.exploreTileBorder,
    required this.pillDark,
    required this.lockCircle,
    required this.lockGlyph,
    required this.bellBorder,
    required this.moodCardStart,
    required this.moodCardEnd,
    required this.navInactive,
    required this.avatarBacking,
    required this.streakRing,
    required this.journalAccent,
    required this.promptCard,
    required this.dayCircle,
    required this.weekNavPill,
    required this.moodCardFill,
    required this.onboardingSurface,
    required this.onboardingRaised,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textBlack,
    required this.textInk,
    required this.textSecondary,
    required this.textMuted,
    required this.textSubtitle,
    required this.onPrimary,
    required this.cardBorder,
    required this.optionBorder,
    required this.segmentBorder,
    required this.searchBorder,
    required this.planCardBorder,
    required this.planBorder,
    required this.planSelectedFill,
    required this.trialBanner,
    required this.toggleTrack,
    required this.periodToggleBorder,
    required this.planEmphasisFill,
    required this.topicChipBorder,
    required this.unreadDot,
    required this.notificationCardBorder,
    required this.chipOutline,
    required this.aiStatLabel,
    required this.aiStatValue,
    required this.aiDivider,
    required this.segmentTrack,
    required this.segmentTrackBorder,
    required this.calendarCardBorder,
    required this.skeleton,
    required this.skeletonHighlight,
    required this.dayEmpty,
    required this.entryCardBorder,
    required this.daySelected,
    required this.moodTrackActive,
    required this.moodTrackInactive,
    required this.moodThumb,
    required this.filterChipFill,
    required this.filterChipBorder,
    required this.filterRule,
    required this.topicChipLabel,
    required this.rowBorder,
    required this.divider,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.titleGradientStops,
  });

  final Brightness brightness;

  // Brand
  final Color brandLight;
  final Color brandDeep;
  final Color brandInk;
  final Color primary;

  /// Named "soothify blue" in the Figma file — accent for progress and
  /// selected states.
  final Color soothifyBlue;

  // Actions
  final Color actionFill;
  final Color actionFillDisabled;

  /// The auth screen's CTA is amber in the design, not the app's blue.
  final Color authAccent;

  /// Underline beneath the auth text fields.
  final Color fieldUnderline;

  /// Filled input on the create-account and login screens.
  final Color fieldFill;

  /// "Create your account" / "Log in to your account" heading.
  final Color authHeading;

  /// Password-rule chip background and its label.
  final Color hintChip;
  final Color hintText;
  final Color progressTrack;

  /// Unfilled page dot on the onboarding carousel.
  final Color dotInactive;

  /// Home screen: Explore tile outline, the dark pills
  /// carrying duration and rating, the circle behind a premium lock, and the
  /// ring around the notification bell.
  final Color exploreTileBorder;
  final Color pillDark;
  final Color lockCircle;

  /// The padlock inside [lockCircle] — a pale blue-grey, not the body colour.
  final Color lockGlyph;
  final Color bellBorder;

  /// The Mood Checker card's gradient. Not in the Figma JSON export — the
  /// plugin carried no fill for that frame — so these came from the designer
  /// directly.
  final Color moodCardStart;
  final Color moodCardEnd;

  /// Bottom nav: inactive labels are a flat grey, not the body text colour.
  final Color navInactive;

  /// Tint behind the header avatar photo.
  final Color avatarBacking;

  /// Outline of a day not yet reached in the streak strip.
  final Color streakRing;

  /// The Journal compose button — a cyan of its own, not the brand blue.
  final Color journalAccent;

  /// The pale card carrying the writing prompt.
  final Color promptCard;

  /// Empty day marker in the mood-record week strip.
  final Color dayCircle;

  /// Pill holding the previous/next week arrows.
  final Color weekNavPill;

  /// Selected-day detail card. The design specifies #00AEEF at 10% over the
  /// page; these are the composited results per background.
  final Color moodCardFill;

  // Onboarding (dark A/B variant surfaces)
  final Color onboardingSurface;
  final Color onboardingRaised;

  // Surfaces
  final Color background;
  final Color surface;
  final Color surfaceAlt;

  // Text
  final Color textPrimary;
  final Color textBlack;
  final Color textInk;
  final Color textSecondary;
  final Color textMuted;
  final Color textSubtitle;
  final Color onPrimary;

  // Lines
  final Color cardBorder;
  final Color optionBorder;

  /// Outline on a Profile segmented-control pill — #263238 at 50%, so a
  /// mid grey rather than the black a naive read of the fill would give.
  final Color segmentBorder;

  /// Discovery search field hairline — #999999 at 10%.
  final Color searchBorder;

  /// The "Unlock every feature" card's own outline.
  final Color planCardBorder;

  /// An unselected plan row — #787880 at 16%.
  final Color planBorder;

  /// The selected plan row's tint, under a [soothifyBlue] hairline.
  final Color planSelectedFill;

  /// The free-trial banner behind the toggle.
  final Color trialBanner;

  /// iOS-style toggle track, off.
  final Color toggleTrack;

  /// The Monthly/Annual pill's outer hairline.
  final Color periodToggleBorder;

  /// The emphasised plan card's fill. Deliberately the same deep blue in both
  /// themes: it is a brand surface carrying white text, and following
  /// [brandInk] inverted it to a pale blue in dark mode, which left that text
  /// barely legible.
  final Color planEmphasisFill;

  /// The red mark on an unread notification.
  final Color unreadDot;

  /// The hairline around the Reminder card, and around an unchosen filter
  /// chip.
  final Color notificationCardBorder;
  final Color chipOutline;

  /// The AI Hub's stat row — a grey caption over a near-black value — and the
  /// rule beneath it.
  final Color aiStatLabel;
  final Color aiStatValue;
  final Color aiDivider;

  /// The "Select Environment Vibe" segmented control: a white track with a
  /// hairline, the chosen segment filled with [actionFill].
  final Color segmentTrack;
  final Color segmentTrackBorder;

  /// A loading placeholder block, and the highlight that sweeps across it.
  final Color skeleton;
  final Color skeletonHighlight;

  /// A mood check-in day with nothing recorded against it.
  final Color dayEmpty;

  /// The blue-grey hairline around a single check-in entry's card.
  final Color entryCardBorder;

  /// The hairline around the History calendar's card.
  final Color calendarCardBorder;

  /// The circle behind the chosen day on the History calendar — the design's
  /// orange, not the blue every other calendar in the app selects with.
  final Color daySelected;

  /// The Mood Checker slider — measured off the frames. The filled side is a
  /// softer blue than the handle, and the empty side is the same grey in both
  /// themes.
  final Color moodTrackActive;
  final Color moodTrackInactive;
  final Color moodThumb;

  /// A filter sheet's chip — an off-white fill inside a hairline of the body
  /// ink, per the three filter frames. Unlike a Community topic chip, the
  /// unselected state already carries an outline, so selection is shown by
  /// filling the chip rather than by adding a border.
  final Color filterChipFill;
  final Color filterChipBorder;

  /// The 2px rule between groups on More Filters.
  final Color filterRule;

  /// An unselected topic chip's outline — #999999 at 30%.
  final Color topicChipBorder;

  /// A topic chip's label — #1B1F26 at 72%.
  final Color topicChipLabel;

  /// Hairline around an unselected language row.
  final Color rowBorder;
  final Color divider;

  // Status
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;

  final List<Color> titleGradientStops;

  Color get transparent => Colors.transparent;

  bool get isDark => brightness == Brightness.dark;

  /// "Soothify Gradient - 01" — the auth screen header, 139.5 degrees.
  LinearGradient get authHeaderGradient => const LinearGradient(
    begin: Alignment(-0.86, -0.51),
    end: Alignment(0.86, 0.51),
    colors: [Color(0xFF2F6FED), Color(0xFF274889)],
    stops: [0.028, 0.531],
  );

  /// Mood Checker card fill. Direction is an assumption — a wide card most
  /// often runs left to right — so correct this if the design differs.
  LinearGradient get moodCardGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [moodCardStart, moodCardEnd],
  );

  /// The active bottom-nav tab. A different pair from [titleGradient] —
  /// measured from the nav component itself.
  LinearGradient get navActiveGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4B84F6), Color(0xFF0A399A)],
  );

  /// Profile "My stats" card — vertical, light at the top.
  ///
  /// Taken from a PNG render of the frame, not from `gradientHandlePositions`.
  /// Those handles (start 0.5,-0.11 to end -1.93,1.10) convert to a long
  /// mostly-leftward vector that renders as a near-flat wash; the frame Figma
  /// actually draws is plainly top-to-bottom. The stops are the measured ones,
  /// and they are what hold the flat light band at the top and dark band at
  /// the bottom.
  LinearGradient get statsCardGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4B84F6), Color(0xFF0A399A)],
    stops: [0.203, 0.839],
  );

  /// The Schedule cards. Each offering has its own fill in the design: the
  /// therapy card reuses [navActiveGradient], and these two are its siblings.
  LinearGradient get meditationSessionGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF09D39), Color(0xFFCB6F00), Color(0xFFF1880A)],
  );

  LinearGradient get balanceSessionGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF09D39), Color(0xFF0A399A)],
  );

  /// Splash / brand gradient, top-left to bottom-right.
  LinearGradient get brandGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandLight, brandDeep],
  );

  /// Onboarding title fill. In light the design paints the text with a
  /// near-vertical gradient under a 20% black overlay, folded into the stops
  /// here so one shader reproduces it.
  LinearGradient get titleGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: titleGradientStops,
    stops: const [0.0, 0.532],
  );

  static const PrimaryColors light = PrimaryColors(
    brightness: Brightness.light,
    brandLight: Color(0xFF4B84F6),
    brandDeep: Color(0xFF1F2EB1),
    brandInk: Color(0xFF0A399A),
    primary: Color(0xFF4B84F6),
    soothifyBlue: Color(0xFF2F6FED),
    actionFill: Color(0xFF2233B5),
    actionFillDisabled: Color(0xFFC5CCED),
    authAccent: Color(0xFFF09D39),
    fieldUnderline: Color(0x70000000),
    fieldFill: Color(0xFFF9F9F9),
    authHeading: Color(0xFF10086A),
    hintChip: Color(0xFFF9F9F9),
    hintText: Color(0xFF999999),
    progressTrack: Color(0xFFECF1F4),
    dotInactive: Color(0xFFEDEDED),
    exploreTileBorder: Color(0x1FEADDFF),
    pillDark: Color(0xFF484747),
    lockCircle: Color(0xFFECECEC),
    lockGlyph: Color(0xFFC1C9DB),
    bellBorder: Color(0xFFCBD0D8),
    moodCardStart: Color(0xFF2C3FE3),
    moodCardEnd: Color(0xFF142088),
    navInactive: Color(0xFF999999),
    avatarBacking: Color(0xFFB8DFF2),
    streakRing: Color(0xFF999B9E),
    journalAccent: Color(0xFF00AEEF),
    promptCard: Color(0xFFE1EBFF),
    dayCircle: Color(0xFFF2C288),
    weekNavPill: Color(0xFFCCC9C9),
    moodCardFill: Color(0xFFDCF2FC),
    onboardingSurface: Color(0xFF465A8C),
    onboardingRaised: Color(0xFF566CA4),
    background: Color(0xFFF5FBFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF2F2F2),
    textPrimary: Color(0xFF263238),
    textBlack: Color(0xFF000000),
    textInk: Color(0xFF0D0F2C),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xB81B1F26),
    textSubtitle: Color(0xE6323233),
    onPrimary: Color(0xFFFFFFFF),
    cardBorder: Color(0x0D000000),
    optionBorder: Color(0x0D263238),
    segmentBorder: Color(0x80263238),
    searchBorder: Color(0x1A999999),
    planCardBorder: Color(0xFFF2F2F7),
    planBorder: Color(0x29787880),
    planSelectedFill: Color(0xFFF2F6FF),
    trialBanner: Color(0xFFE6F2FF),
    toggleTrack: Color(0xFFE9E9EA),
    periodToggleBorder: Color(0xFFD7D7D7),
    planEmphasisFill: Color(0xFF0A399A),
    topicChipBorder: Color(0x4D999999),
    unreadDot: Color(0xFFF45A4F),
    notificationCardBorder: Color(0xFFE6EBEE),
    chipOutline: Color(0xFFECEDED),
    aiStatLabel: Color(0xFF72737A),
    aiStatValue: Color(0xFF1B1F26),
    aiDivider: Color(0xFFEBF1F5),
    segmentTrack: Color(0xFFFEFEFE),
    segmentTrackBorder: Color(0xFFEAEAEA),
    calendarCardBorder: Color(0xFFD8D8D8),
    skeleton: Color(0xFFE8EEF4),
    skeletonHighlight: Color(0xFFF7FAFD),
    dayEmpty: Color(0xFFEAE7E3),
    entryCardBorder: Color(0xFF778AB2),
    daySelected: Color(0xFFFF9500),
    moodTrackActive: Color(0xFF638FE8),
    moodTrackInactive: Color(0xFFDADADA),
    moodThumb: Color(0xFF2F6FED),
    filterChipFill: Color(0xFFFEFEFE),
    filterChipBorder: Color(0xFF263238),
    filterRule: Color(0xFF999999),
    topicChipLabel: Color(0xB81B1F26),
    rowBorder: Color(0xFFCCCCCC),
    divider: Color(0xFFEDE9E3),
    accent: Color(0xFFF5A623),
    success: Color(0xFF34C759),
    warning: Color(0xFFF5A623),
    error: Color(0xFFC0392B),
    titleGradientStops: [Color(0xFF2659BE), Color(0xFF1F3A6E)],
  );

  /// Charcoal dark mode, from variant A of the design's A/B pair.
  static const PrimaryColors dark = PrimaryColors(
    brightness: Brightness.dark,
    brandLight: Color(0xFF4B84F6),
    brandDeep: Color(0xFF1F2EB1),
    brandInk: Color(0xFF7FA8FF),
    primary: Color(0xFF4B84F6),
    // Lifted from the light value so it still reads against charcoal.
    soothifyBlue: Color(0xFF4B84F6),
    actionFill: Color(0xFF2F6FED),
    actionFillDisabled: Color(0xFF2C3563),
    authAccent: Color(0xFFF09D39),
    fieldUnderline: Color(0x70FFFFFF),
    fieldFill: Color(0xFF2A2828),
    authHeading: Color(0xFF9CC0FF),
    hintChip: Color(0xFF2A2828),
    hintText: Color(0xFF9A9A9A),
    progressTrack: Color(0xFF3C3939),
    dotInactive: Color(0xFF3C3939),
    exploreTileBorder: Color(0xFF4A4747),
    pillDark: Color(0xFF1E1D1D),
    lockCircle: Color(0xFF3C3939),
    lockGlyph: Color(0xFF8A93A6),
    bellBorder: Color(0xFF4A4747),
    moodCardStart: Color(0xFF2C3FE3),
    moodCardEnd: Color(0xFF142088),
    navInactive: Color(0xFF8A8A8A),
    avatarBacking: Color(0xFF2A4552),
    streakRing: Color(0xFF6B6D70),
    journalAccent: Color(0xFF00AEEF),
    promptCard: Color(0xFF20304F),
    dayCircle: Color(0xFFF2C288),
    weekNavPill: Color(0xFF3C3939),
    moodCardFill: Color(0xFF102D37),
    onboardingSurface: Color(0xFF2A3550),
    onboardingRaised: Color(0xFF3B4966),
    background: Color(0xFF131414),
    surface: Color(0xFF423F3F),
    surfaceAlt: Color(0xFF3C3939),
    textPrimary: Color(0xFFFEFEFE),
    // On charcoal the "black text" role inverts to near-white.
    textBlack: Color(0xFFFEFEFE),
    textInk: Color(0xFFFEFEFE),
    textSecondary: Color(0xFFB9BCBC),
    textMuted: Color(0xB8FEFEFE),
    textSubtitle: Color(0xE6FEFEFE),
    onPrimary: Color(0xFFFFFFFF),
    cardBorder: Color(0x14FFFFFF),
    optionBorder: Color(0x14FFFFFF),
    segmentBorder: Color(0x66FFFFFF),
    searchBorder: Color(0x33FFFFFF),
    planCardBorder: Color(0x1FFFFFFF),
    planBorder: Color(0x33FFFFFF),
    planSelectedFill: Color(0x1F2F6FED),
    trialBanner: Color(0x1F2F6FED),
    toggleTrack: Color(0xFF4A4A4C),
    periodToggleBorder: Color(0x33FFFFFF),
    planEmphasisFill: Color(0xFF0A399A),
    topicChipBorder: Color(0x4DFFFFFF),
    unreadDot: Color(0xFFF45A4F),
    notificationCardBorder: Color(0xFF33383B),
    chipOutline: Color(0xFF3A3838),
    aiStatLabel: Color(0xFF9AA0A6),
    aiStatValue: Color(0xFFFEFEFE),
    aiDivider: Color(0xFF2A2828),
    segmentTrack: Color(0xFF423F3F),
    segmentTrackBorder: Color(0xFF3A3838),
    calendarCardBorder: Color(0xFF3A3838),
    skeleton: Color(0xFF2A2C2E),
    skeletonHighlight: Color(0xFF3A3D40),
    dayEmpty: Color(0xFF35322F),
    entryCardBorder: Color(0xFF4A5875),
    daySelected: Color(0xFFFF9500),
    moodTrackActive: Color(0xFF4079EA),
    moodTrackInactive: Color(0xFFDADADA),
    moodThumb: Color(0xFF2F6FED),
    filterChipFill: Color(0xFF423F3F),
    filterChipBorder: Color(0xFFFEFEFE),
    filterRule: Color(0xFF5A5757),
    topicChipLabel: Color(0xDEFFFFFF),
    rowBorder: Color(0xFF4A4747),
    divider: Color(0xFF2A2828),
    accent: Color(0xFFF5A623),
    success: Color(0xFF34C759),
    warning: Color(0xFFF5A623),
    // Brightened so it stays legible on a dark ground.
    error: Color(0xFFFF6B5E),
    titleGradientStops: [Color(0xFF9CC0FF), Color(0xFF4B84F6)],
  );

  /// Palette matching whatever is currently rendered. Defaults to light so a
  /// widget built before the first sync still resolves.
  static PrimaryColors active = light;

  /// Points [appTheme] at the palette for the theme in [context].
  ///
  /// Called from the app builder, which rebuilds whenever the active
  /// [ThemeData] changes — including a change in the system setting — so this
  /// stays correct without anything else observing brightness.
  static void syncFrom(BuildContext context) {
    active = Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  static PrimaryColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

class ThemeHelper {
  const ThemeHelper._();

  static ThemeData get lightTheme => _build(PrimaryColors.light);
  static ThemeData get darkTheme => _build(PrimaryColors.dark);

  static ThemeData _build(PrimaryColors c) {
    final colorScheme = ColorSchemes.of(c);

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: CustomTextStyles.fontNunitoSans,
      // Built from the palette explicitly rather than the global, so both
      // ThemeData objects can be constructed regardless of which is active.
      textTheme: CustomTextStyles.textThemeFor(c),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: CustomTextStyles.appBarTitleFor(c),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.actionFill,
          foregroundColor: c.onPrimary,
          elevation: 0,
          minimumSize: Size.fromHeight(52.v),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.h),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.cardBorder),
          minimumSize: Size.fromHeight(52.v),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.h),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.v),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.h),
          borderSide: BorderSide(color: c.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.h),
          borderSide: BorderSide(color: c.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.h),
          borderSide: BorderSide(color: c.soothifyBlue, width: 1.5),
        ),
      ),
    );
  }
}

class ColorSchemes {
  const ColorSchemes._();

  static ColorScheme of(PrimaryColors c) => ColorScheme(
    brightness: c.brightness,
    primary: c.soothifyBlue,
    onPrimary: c.onPrimary,
    secondary: c.accent,
    onSecondary: c.textPrimary,
    surface: c.surface,
    onSurface: c.textPrimary,
    error: c.error,
    onError: c.onPrimary,
  );
}
