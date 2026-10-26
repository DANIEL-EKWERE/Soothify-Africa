import 'booked_session.dart';
import 'media_item.dart';

/// The wellness coach a booking is matched with — Figma "Matched with
/// instructor" (135:20932).
///
/// A view model: the screen's own shape, assembled from whatever the match
/// returned. [MatchedExpert] is the wire shape; this is what the frame
/// prints, which is not the same list of fields.
class Coach {
  const Coach({
    required this.name,
    required this.matchPercent,
    required this.blurb,
    required this.feelings,
    required this.quote,
    required this.outside,
    required this.expertise,
    this.videoTitles = const [],
    this.videos = const [],
    this.peers = const [],
    this.avatarUrl = '',
  });

  final String name;

  /// 0-100. The design prints "98% Match".
  final int matchPercent;

  final String blurb;

  /// The "Because you like" chips.
  /// The chips under "Because you feel...".
  final List<String> feelings;

  final String quote;

  /// The "Outside of Soothify" lines.
  final List<String> outside;

  final List<String> expertise;

  /// The frame's own trending titles, with nothing behind them. Kept for
  /// [sample] and the no-backend build; [videos] is what the server sends.
  final List<String> videoTitles;

  /// Their library, credited to them by the upload form's practitioner
  /// link. Empty where they have published nothing yet, and then the row is
  /// left out rather than drawn with placeholders.
  final List<MediaItem> videos;

  /// The others who also matched, for the row of faces. Empty falls back to
  /// the frame's asset portraits.
  final List<ExpertPeer> peers;

  /// Their portrait, where the server has one. Empty falls back to the
  /// frame's own photo.
  final String avatarUrl;

  /// The matched expert, as the screen reads them.
  ///
  /// `feelings` is the one part that is not about the expert at all: the
  /// chips answer "Because you feel..." and come from what the client said
  /// in the questionnaire, which is why they are passed in rather than
  /// read off the match.
  factory Coach.fromMatch(MatchedExpert match, {List<String> feelings = const []}) {
    return Coach(
      name: match.name,
      // The server earns this from the discipline, the hour, the language
      // and the rating; the frame prints "98% Match".
      matchPercent: match.matchPercent,
      blurb: match.bio.isNotEmpty ? match.bio : match.headline,
      feelings: feelings,
      quote: match.quote,
      // Their own words from the application form, where there are any.
      // Older profiles have only the interests list, which is what this
      // read before the form asked the question.
      outside: match.outsideWork.isNotEmpty
          ? [match.outsideWork]
          : match.interests,
      expertise: match.disciplines.map(_titled).toList(),
      // Their actual library, credited to them by the upload form's
      // practitioner link. The row used to draw the frame's own titles
      // with nothing behind them.
      videos: match.videos,
      peers: match.others,
      avatarUrl: match.avatarUrl,
    );
  }

  /// 'therapy' -> 'Therapy'. The server stores the app's own keys.
  static String _titled(String key) =>
      key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);

  /// The design mixes two names — the header says "Baraqhat Ibrahim" while
  /// "Find Melody Briggs" and one variant's trending row say "Melody Briggs".
  /// One coach is rendered throughout; confirm which name is intended.
  static const Coach sample = Coach(
    name: 'Baraqhat Ibrahim',
    matchPercent: 98,
    // The frame writes "Practicing yoga with Melody Briggs" on Baraqhat's
    // own profile — a name left over from another card. The coach's name is
    // substituted rather than printed as drawn.
    blurb: 'We believe that fitness is part of your journey\n'
        'to authenticity. Practicing yoga with Baraqhat Ibrahim will help '
        'you tap into your emotions, physically challenge yourself, and find '
        'joy in movement,',
    // The chips answer "Because you feel...", so they are moods, not
    // interests. They were "Heartfelt Coaching / Pop Music / Yoga" under an
    // older heading that read "Because you like".
    feelings: [
      'Anxious',
      'Stressed',
      'Low',
      'Drained',
      'Overwhelmed',
    ],
    quote: '“Live your life in your truth.”',
    outside: [
      'Pop music lover',
      'Enjoys being active and spending time with friends',
    ],
    expertise: ['Yoga', 'Meditation'],
    videoTitles: ['Unshakeable', 'Unshakeable', 'Unshakeable'],
  );
}
