import '../../core/utils/image_constant.dart';
import 'session_offering.dart';

/// The questionnaire a section shows before its booking flow.
///
/// Each section gates its sessions behind one and asks its own questions;
/// only the shape is shared.
///
/// Rewritten for Pilates & Core from `Pilates kyc` (259:38525 for the intro,
/// then 259:38083 / 38121 / 38155 / 38196 / 38236 / 38252). The design drew
/// each question twice — once with "Next" and once with "Continue" — which is
/// the same step, not two.
///
/// Each card of "Book a licensed expert screen" (259:31488) opens its own
/// track: the Pilates card [meditation], the yoga card [balance] and the
/// therapy card [therapy] (the row closing on `Matching Therapist`
/// 259:58834, still unread).
///
/// [balance] is both Stretch & Restore's section questionnaire and the yoga
/// card's — `Scheduling Kyc/Yoga` plus the `Yoga Kyc` row is one thing, and
/// the card reaches it without the interstitial the section shows.
class WellnessKycStep {
  const WellnessKycStep({
    required this.question,
    required this.options,
    this.multiSelect = false,
    this.optionIcons = const [],
  });

  final String question;
  final List<String> options;

  /// A glyph per option, aligned to [options] by index. Empty — which is
  /// every question but one — means text-only tiles.
  ///
  /// Only the therapy track's "How do you want to have your sessions?"
  /// (`259:38702`) draws icons: a handset over "Audio only" and a camcorder
  /// over "Video call".
  final List<String> optionIcons;

  /// The glyph for [option], or null where the question has none.
  String? iconFor(String option) {
    final i = options.indexOf(option);
    return i >= 0 && i < optionIcons.length ? optionIcons[i] : null;
  }

  /// The design marks these with "You can select more than one option".
  final bool multiSelect;
}

/// Which section's questionnaire is running.
enum WellnessTrack {
  meditation(
    'Pilates & Core',
    [
      WellnessKycStep(
        question: 'How experienced are you with Pilates?',
        options: ['Total beginner', 'I know the basics', 'Very experienced'],
      ),
      WellnessKycStep(
        question: 'How often do you want to practice?',
        options: [
          'Just starting out',
          'A couple times a week',
          'Almost every day',
        ],
      ),
      WellnessKycStep(
        question: 'What do you want to focus on most?',
        options: [
          'Building core strength',
          'Fixing my posture',
          'Postpartum recovery',
          'Overall toning',
        ],
        multiSelect: true,
      ),
      WellnessKycStep(
        question: 'Any specific spots you want to work on?',
        options: [
          'Lower back',
          'Pelvic floor and core',
          'Shoulders and upper body',
          'Full body',
        ],
        multiSelect: true,
      ),
      WellnessKycStep(
        question: 'How active are you right now?',
        options: ['Not very active', 'Moderately active', 'Very active'],
      ),
      // No "pick as many" line on this frame, unlike the two above it — so
      // one answer, which is also why "None" is among the options.
      WellnessKycStep(
        question: 'Anything we should keep in mind to keep you safe?',
        options: [
          'Recovering postpartum',
          'Diastasis recti',
          'Sensitive joints',
          'None',
        ],
      ),
    ],
    introTitle: 'Let’s set up your Pilates session',
    introBody: 'Answer a few quick questions so we can find the right '
        'instructor for you',
    multiHint: 'Pick as many as you like',
  ),
  balance(
    'Stretch & Restore',
    [
      WellnessKycStep(
        question: 'Where are you currently at with your yoga practice?',
        // The frame writes "Finding my rhythm " with a trailing space.
        options: ['Beginner', 'Finding my rhythm', 'Deeply familiar'],
      ),
      WellnessKycStep(
        question: 'How often do you step onto the mat?',
        // "Most days." carries a full stop its siblings do not; dropped as a
        // slip, the way the app drops the frames' other typos.
        options: [
          'Just beginning',
          'A few intentional times a week',
          'Most days',
        ],
        // The frame marks this one "You can select more than one option",
        // which is odd for a frequency question — Pilates asks the same
        // thing single-select. Honoured as drawn. Confirm.
        multiSelect: true,
      ),
      WellnessKycStep(
        question: 'What are you hoping to cultivate through your practice?',
        // "Cultivating inner strength." likewise loses its full stop.
        options: [
          'Releasing stress & tension',
          'Building flexibility & ease',
          'Cultivating inner strength',
          'Others',
        ],
        multiSelect: true,
      ),
    ],
    // `Scheduling Kyc/Yoga` (259:38802) is this section's intro, and the
    // `Yoga Kyc` row behind it is this section's questions. That frame has
    // been assigned twice before and moved twice; it belongs here.
    //
    // Only 259:25803, 25816 and 25831 have been read. Four remain —
    // 259:25848, 25868, 25886, 25899 — so this is three questions where the
    // design draws seven. The six it replaces came from the archived
    // `Balance Kyc` row (y>62000) and are no longer what the design asks.
    introTitle: 'Tailoring your practice',
    introBody: 'Tell us a little about your body and your rhythm so we can '
        'pair you with the right guide.',
  ),

  /// The therapy card — Figma's `Scheduling Kyc/balance/meditation` row,
  /// which despite the name is the **therapy** questionnaire: it opens on
  /// `259:38773` ("Let's find the right therapist for you") and closes on
  /// `Matching Therapist` (259:58834).
  ///
  /// Six question frames, which are three questions drawn twice — once
  /// unanswered and once with a tile chosen: 259:38665/38719,
  /// 259:38686/38740, 259:38702/38756.
  ///
  /// It previously held the old file's five generic questions as
  /// placeholders, the first of which offered Hatha Yoga, Ashtanga Vinyasa
  /// and Prenatal Yoga — so the therapy card opened a yoga questionnaire.
  therapy(
    '1-on-1 virtual therapy session',
    [
      WellnessKycStep(
        // The answered twin (259:38719) still carries the old heading,
        // "What type of wellness sessions are you interested in?", over these
        // same six options. Left behind when the copy was rewritten.
        question: 'What’s on your mind right now?',
        options: [
          'Dealing with a lot of stress or burnout',
          'Feeling anxious',
          'Feeling low or overwhelmed',
          'Relationship or family issues',
          'Going through a big life change',
          'Something else',
        ],
        multiSelect: true,
      ),
      WellnessKycStep(
        question: 'What kind of therapist do you prefer?',
        options: [
          'Someone warm and just listens',
          'Someone practical with clear steps',
          'Someone who shares my background',
          'No preference',
        ],
      ),
      WellnessKycStep(
        question: 'How do you want to have your sessions?',
        options: ['Audio only (camera off)', 'Video call'],
        optionIcons: [ImageConstant.icPhoneCall, ImageConstant.icVideoCall],
      ),
    ],
    introTitle: 'Let’s find the right therapist for you',
    introBody: 'Tell us a bit about what’s going on so we can pair you with '
        'someone good',
    multiHint: 'Pick as many as you like',
  );

  const WellnessTrack(
    this.title,
    this.steps, {
    this.introTitle = '',
    this.introBody = '',
    this.multiHint = 'You can select more than one option',
  });

  /// The header title — the frames differ only here, which is why the
  /// Meditation and Schedule intros read identically otherwise.
  final String title;

  final List<WellnessKycStep> steps;

  /// The intro's heading and its paragraph. The sections used to share one
  /// line; they now each have their own — see [intro] for the fallback.
  final String introTitle;
  final String introBody;

  /// The line under a multi-select question. Pilates & Core says "Pick as
  /// many as you like"; the others keep the older wording.
  final String multiHint;

  /// Older tracks whose intro has not been re-read still show the shared
  /// line the previous file gave all three.
  String get intro => introBody.isNotEmpty
      ? introBody
      : 'Tell us a little about yourself, and we’ll match you with the '
          'perfect wellness coach';

  /// The heading above [intro], when the track has one of its own.
  String get heading => introTitle;

  /// What this questionnaire is booking, so the matching screen can name the
  /// discipline it is searching for.
  SessionOffering get offering => switch (this) {
        WellnessTrack.meditation => SessionOffering.meditation,
        WellnessTrack.balance => SessionOffering.balance,
        WellnessTrack.therapy => SessionOffering.therapy,
      };

  String get prefKey => 'wellnessKyc_$name';
}
