import '../../routes/app_routes.dart';
import 'article.dart';
import 'checkin_kind.dart';
import 'session_invite.dart';

/// What a push says to open.
///
/// The server sends a flat `data` map — FCM allows nothing else — so this is
/// the one place that turns strings into a route and its arguments. Keeping
/// it a plain function of a map is what lets the routing be tested without a
/// device, a Firebase project or a notification being delivered.
enum PushTopic {
  /// A booked session is starting. Opens the waiting room, as tapping the
  /// same row in the feed does.
  session('session'),

  /// The 60-second breathing minute.
  breathe('breathe'),

  /// A daily habit's reminder — the one this app schedules locally rather
  /// than receives.
  daily('daily'),

  /// "New article posted".
  article('article'),

  /// Time to record a mood.
  mood('mood'),

  /// Anything else, including a push with no type at all: the feed, which
  /// can show whatever arrived.
  feed('feed');

  const PushTopic(this.wire);

  /// The value the server puts in `data['type']`.
  final String wire;

  static PushTopic parse(String? value) => values.firstWhere(
    (t) => t.wire == value,
    orElse: () => PushTopic.feed,
  );
}

/// A route and its arguments, ready for `Get.toNamed`.
typedef PushDestination = ({String route, Object? arguments});

/// Where a push's `data` map should land the user.
///
/// Unknown and malformed payloads fall back to the notification feed rather
/// than being dropped: a push the user was shown must always open something,
/// and the feed is the one screen that can carry any of them.
PushDestination destinationFor(Map<String, dynamic> data) {
  final topic = PushTopic.parse(data['type'] as String?);
  String text(String key) => (data[key] as String?)?.trim() ?? '';

  switch (topic) {
    case PushTopic.session:
      final service = text('service');
      return (
        route: AppRoutes.clientJoining,
        arguments: SessionInvite(
          expertName: text('expert').isEmpty ? 'your coach' : text('expert'),
          service: service.isEmpty ? '1-on-1 Therapy' : service,
          // The waiting room prints both verbatim, so an absent one has to
          // be empty rather than "null".
          time: text('time'),
          date: text('date'),
        ),
      );

    case PushTopic.breathe:
      return (route: AppRoutes.breathe, arguments: null);

    case PushTopic.daily:
      final kind = CheckinKind.values.firstWhere(
        (k) => k.name == text('habit'),
        orElse: () => CheckinKind.meditation,
      );
      return (route: AppRoutes.daily, arguments: kind);

    case PushTopic.article:
      final article = Article.values.firstWhere(
        (a) => a.name == text('id'),
        orElse: () => Article.core,
      );
      return (route: AppRoutes.article, arguments: article);

    case PushTopic.mood:
      return (route: AppRoutes.moodChecker, arguments: null);

    case PushTopic.feed:
      return (route: AppRoutes.notifications, arguments: null);
  }
}
