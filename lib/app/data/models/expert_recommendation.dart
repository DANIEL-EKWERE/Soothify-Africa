import '../../core/utils/image_constant.dart';

/// What the expert pointed the client at, and how the card labels it.
///
/// The three cards on `259:60761` carry three different actions — "Watch
/// video", "Read Article" and "Listen" — so the label is the kind's, not one
/// shared string.
enum ExpertContentKind {
  video('Video', 'Watch video'),
  article('Article', 'Read Article'),
  audio('Audio', 'Listen');

  const ExpertContentKind(this.label, this.action);

  /// The blue kicker on the detail screen (`259:60842`).
  final String label;

  /// The row label on a session card, and the button on the detail screen.
  final String action;
}

/// The piece of content under "Recommended Content".
class ExpertContent {
  const ExpertContent({
    required this.kind,
    required this.title,
    required this.meta,
    required this.coverAsset,
  });

  final ExpertContentKind kind;

  final String title;

  /// "5 min Mindfulness & Stress Relief".
  final String meta;

  final String coverAsset;
}

/// What an expert left in the client's journal — Figma "Expert
/// Recommendation" (`259:60761`), the Journal's second tab, and "Journal"
/// (`259:60842`), one card's detail.
class ExpertRecommendation {
  const ExpertRecommendation({
    required this.id,
    required this.expertName,
    required this.sessionLabel,
    required this.recordedAt,
    required this.note,
    required this.content,
    this.isNew = false,
    this.avatarAsset = ImageConstant.imgAvatarFemale,
  });

  final String id;

  final String expertName;

  /// "Therapy 1-on-1 Therapy" in the frame — the service, then the format.
  final String sessionLabel;

  final DateTime recordedAt;

  /// The body of "Expert's Note".
  final String note;

  final ExpertContent content;

  /// Unread. The frame gives the first card a red "New" pill and puts the
  /// unread count on the tab itself.
  final bool isNew;

  /// Portrait, reused from the notification feed rather than exported twice.
  final String avatarAsset;

  /// The three the design draws, newest first.
  ///
  /// Nothing writes these — they come from an expert after a session — so
  /// these are the frame's own rows rather than a list that is always
  /// mysteriously empty. The frame repeats one name, one note and one date
  /// across all three; only the action differs, which is what it is
  /// demonstrating.
  static List<ExpertRecommendation> sample({DateTime Function()? now}) {
    final at = (now ?? DateTime.now)();
    const note = 'There are no limits on topics in your Notepad. Write down '
        'how feel, what you’re planning, or simply something you noticed.';
    return [
      ExpertRecommendation(
        id: '1',
        expertName: 'Dr. Amara Okafor',
        sessionLabel: 'Therapy 1-on-1 Therapy',
        recordedAt: at,
        note: note,
        isNew: true,
        content: const ExpertContent(
          kind: ExpertContentKind.video,
          title: 'Guided Breathing for calm',
          meta: '5 min Mindfulness & Stress Relief',
          coverAsset: '${ImageConstant.contentDir}/breath_work.png',
        ),
      ),
      ExpertRecommendation(
        id: '2',
        expertName: 'Dr. Amara Okafor',
        sessionLabel: 'Therapy 1-on-1 Therapy',
        recordedAt: at.subtract(const Duration(days: 7)),
        note: note,
        content: const ExpertContent(
          kind: ExpertContentKind.article,
          title: 'Guided Breathing for calm',
          meta: '5 min Mindfulness & Stress Relief',
          coverAsset: '${ImageConstant.contentDir}/mindfulness.png',
        ),
      ),
      ExpertRecommendation(
        id: '3',
        expertName: 'Dr. Amara Okafor',
        sessionLabel: 'Therapy 1-on-1 Therapy',
        recordedAt: at.subtract(const Duration(days: 14)),
        note: note,
        content: const ExpertContent(
          kind: ExpertContentKind.audio,
          title: 'Guided Breathing for calm',
          meta: '5 min Mindfulness & Stress Relief',
          coverAsset: '${ImageConstant.contentDir}/daily_focus.png',
        ),
      ),
    ];
  }
}
