/// Route names. Paths are URL-shaped because the app uses GetMaterialApp.router
/// (Navigator 2.0), so these double as deep links.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  /// "Welcome to Soothify" carousel, shown once before language selection.
  static const String intro = '/intro';

  /// "Let's personalize Soothify" gate, ahead of language selection.
  static const String personalize = '/personalize';

  /// Language selection.
  static const String language = '/language';

  static const String signup = '/signup';
  static const String signin = '/signin';

  /// Practitioner entry point. Kept registered but out of the default flow:
  /// the designs cover only the client-side sign-in, so [login] establishes a
  /// user session and this stands in until practitioner auth is designed.
  static const String roleSelect = '/role';
  /// The 'what brings you to Soothify' questionnaire.
  static const String kyc = '/kyc';

  // User (client) role
  /// The signed-in shell holding the five bottom-nav tabs.
  static const String shell = '/home';

  /// The full "Recommended for you" list.
  static const String recommendation = '/recommendation';

  static const String journal = '/journal';
  static const String journalCompose = '/journal/new';

  /// Reached from Profile, not from the bottom navigation.
  static const String settings = '/settings';

  /// One kind of check-in history. Takes a [CheckinKind] argument.
  static const String checkin = '/profile/checkin';

  /// A daily habit's history, and its reminder setup. Both take a
  /// [CheckinKind] argument.
  static const String daily = '/profile/daily';
  static const String dailyReminder = '/profile/daily/reminder';

  /// The community forum, reached from the Community tab's topic step.
  static const String communityForum = '/community/forum';
  static const String communityCompose = '/community/new';

  /// One thread and its replies. Takes the [Discussion] as its argument, so
  /// the card is filled on open rather than refetched.
  static const String communityThread = '/community/thread';

  /// The three Explore destinations on Home.
  ///
  /// [library] serves both Meditation and Balance — the frames are the same
  /// screen with different copy — and takes a [LibrarySection] as its argument.
  static const String library = '/library';
  static const String schedule = '/schedule';

  /// A shelf's "See All" grid. Takes the shelf name as its argument, so one
  /// route serves every shelf in the app.
  static const String shelf = '/shelf';

  /// A media item's detail — player plus written material. Takes
  /// `{'item': MediaItem, 'source': String}` so the header can name the shelf
  /// the card was tapped on.
  static const String media = '/media';

  /// A section's pre-booking questionnaire. Takes a [WellnessTrack] argument;
  /// shown once per track, then skipped.
  static const String wellnessKyc = '/wellness-kyc';

  /// Matching, call, rating and feedback — everything after Schedule.
  static const String booking = '/schedule/booking';

  static const String moodChecker = '/mood';
  static const String moodRecord = '/mood/record';

  // Practitioner role — designs pending; routes reserved.
  static const String practitionerDashboard = '/practitioner';

}
