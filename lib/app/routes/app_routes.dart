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

  /// The client waiting for a booked session to open (`280:26643`) — the
  /// practitioner has its own screen.
  static const String clientJoining = '/session/joining';

  /// "Spaces Around Me" (`282:25161`) — studios near the client, list or
  /// map, reached from Discover. Under the "Client Safety & Trust Screens"
  /// banner: somewhere real and vouched-for to practise.
  static const String spaces = '/spaces';

  /// One studio's profile and the two ways to reach it (`282:25339`).
  static const String studioProfile = '/spaces/studio';

  /// The cancellation policy in full (`280:26738`), reached from the payment
  /// screen's policy panel.
  static const String cancellationPolicy = '/cancellation-policy';

  /// "Book a licensed expert screen" (`259:31488`) — the three 1-on-1
  /// disciplines, reached from Home's Explore tile. The questionnaire comes
  /// after a card is picked, not before the list.
  static const String bookExpert = '/book-expert';

  /// The three filter sheets behind a library's filter glyph. One route each
  /// so no screen has to read its own kind out of the arguments; the
  /// arguments carry only the library's current [FilterSelection], and the
  /// applied selection comes back as the pop result.
  ///
  /// [filterDuration] is the entry point — it links through to the other two.
  static const String filterDuration = '/filters/duration';
  static const String filterMore = '/filters/more';
  static const String filterStyle = '/filters/style';

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

  /// One written piece. Takes an [Article]; one route serves both, as the
  /// two frames differ only in their words.
  static const String article = '/article';

  /// The video library — a shelf per category, each with its own See All.
  static const String videos = '/videos';

  /// Choosing a plan and paying for a booked session. Takes a
  /// [SessionOffering], which carries the two prices and whether the
  /// cancellation policy is spelled out.
  static const String bookingPayment = '/schedule/payment';

  /// The receipt. Takes the same [SessionOffering].
  static const String paymentSuccess = '/schedule/payment/success';

  /// Applying to practise on Soothify. The intro, then the form, which runs
  /// its three steps and the acknowledgement in one route.
  static const String expertApplication = '/expert/apply';
  static const String expertApplicationForm = '/expert/apply/form';

  /// One recommendation an expert left, opened from the Journal's second tab.
  static const String journalRecommendation = '/journal/recommendation';

  /// The subscription pitch. Takes a [SubscriptionOffer]; one route serves
  /// both frames.
  static const String subscriptionOffer = '/subscribe';

  /// The Corporate enquiry — Figma `259:36101`, and its success card
  /// `259:36093`. Reached from "Speak with Corporate Team" on Plans.
  /// The Settings sub-screens — Figma `259:37602` (subscription), `259:37589`
  /// (account), `259:37551` (user profile), `259:37617` (delete), `259:37526`
  /// (notifications) and the three content pages.
  static const String manageSubscription = '/settings/subscription';
  static const String accountSettings = '/settings/account';
  static const String userProfile = '/settings/account/profile';
  static const String deleteAccount = '/settings/account/delete';
  static const String notificationSettings = '/settings/notifications';
  static const String policy = '/settings/policy';

  static const String corporateForm = '/corporate-form';
  static const String corporateSuccess = '/corporate-success';

  /// The notification feed, reached from the bell on Home.
  static const String notifications = '/notifications';

  /// AI Therapy Assist — the floating button's destination. One route for
  /// both frames: the panel expands into the chat in place.
  static const String aiHub = '/ai-hub';

  static const String moodChecker = '/mood';
  /// What the app offers back for the mood just recorded. Takes a
  /// [MoodLevel] argument; one route serves all ten.
  static const String moodRecommendation = '/mood/recommendation';

  static const String moodRecord = '/mood/record';

  // Expert (practitioner) role — Figma's own row of frames at y=4085.
  /// The expert shell holding its five bottom-nav tabs.
  static const String practitionerDashboard = '/practitioner';

  /// "Update Availability", from the dashboard's Quick Actions.
  static const String expertAvailability = '/practitioner/availability';

  /// One window's hours and days. Takes an [AvailabilitySlot].
  static const String expertSlotEditor = '/practitioner/availability/slot';

  /// One session's notes. Takes an [ExpertSession]; the frame is titled after
  /// the client, so a session has to be chosen before it opens.
  static const String expertSessionNotes = '/practitioner/notes';

  /// Withdrawing: the amount, then where it goes.
  static const String expertWithdraw = '/practitioner/withdraw';
  static const String expertPayoutMethod = '/practitioner/payout-method';

  /// The expert's pre-call screen. Takes an [ExpertSession].
  static const String expertJoinSession = '/practitioner/join';

  /// The full payout history, behind Earnings' "See All".
  static const String expertPayouts = '/practitioner/payouts';
}
