import 'session_offering.dart';

/// A session as the server holds it: booked, paid for or finished.
///
/// Distinct from [BookedSlot], which is a choice the user has made and not
/// yet paid for. This one has an id, a status and a room to join, because
/// the server has agreed to it.
class BookedSession {
  const BookedSession({
    required this.id,
    required this.discipline,
    required this.expertName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.priceNaira,
    this.mode = 'video',
    this.roomId = '',
    this.rating,
  });

  final String id;

  /// 'therapy', 'yoga' or 'pilates' — the server's own values.
  final String discipline;
  final String expertName;
  final DateTime startsAt;
  final DateTime endsAt;

  /// 'pending' until it is paid for, then 'confirmed', then 'completed'.
  /// Also 'cancelled' and 'no_show'.
  final String status;

  final int priceNaira;

  /// 'phone' or 'video', chosen on the booking screen.
  final String mode;

  /// What both sides join for the call. Empty until the server says.
  final String roomId;

  final int? rating;

  bool get isPaid => status == 'confirmed' || status == 'completed';
  bool get awaitingPayment => status == 'pending';
  bool get canBeRated => status == 'completed' && rating == null;

  /// The offering this maps to, for the screens that still speak in those
  /// terms. Pilates and yoga both sit under the app's two movement
  /// sections; therapy is its own.
  SessionOffering get offering => switch (discipline) {
        'yoga' => SessionOffering.balance,
        'pilates' => SessionOffering.meditation,
        _ => SessionOffering.therapy,
      };

  factory BookedSession.fromJson(Map<String, dynamic> json) => BookedSession(
        id: '${json['id']}',
        discipline: json['discipline'] as String? ?? 'therapy',
        expertName: json['expert_name'] as String? ?? '',
        startsAt: DateTime.tryParse('${json['starts_at']}')?.toLocal() ??
            DateTime.now(),
        endsAt: DateTime.tryParse('${json['ends_at']}')?.toLocal() ??
            DateTime.now(),
        status: json['status'] as String? ?? 'pending',
        priceNaira: json['price_naira'] as int? ?? 0,
        mode: json['mode'] as String? ?? 'video',
        roomId: json['room_id'] as String? ?? '',
        rating: json['rating'] as int?,
      );
}

/// The expert a client is matched with, and how good the match is.
class MatchedExpert {
  const MatchedExpert({
    required this.id,
    required this.name,
    this.headline = '',
    this.bio = '',
    this.quote = '',
    this.disciplines = const [],
    this.languages = const [],
    this.interests = const [],
    this.yearsExperience = 0,
    this.rating = 0,
    this.avatarUrl = '',
    this.matchPercent = 0,
  });

  final String id;
  final String name;
  final String headline;
  final String bio;
  final String quote;
  final List<String> disciplines;
  final List<String> languages;
  final List<String> interests;
  final int yearsExperience;
  final double rating;
  final String avatarUrl;

  /// The design's "98% Match". Earned server-side from the discipline, the
  /// hour, the language and the rating — not decoration.
  final int matchPercent;

  factory MatchedExpert.fromJson(Map<String, dynamic> json) => MatchedExpert(
        id: '${json['id']}',
        name: json['name'] as String? ?? '',
        headline: json['headline'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        quote: json['quote'] as String? ?? '',
        disciplines: _strings(json['disciplines']),
        languages: _strings(json['languages']),
        interests: _strings(json['interests']),
        yearsExperience: json['years_experience'] as int? ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        avatarUrl: json['avatar_url'] as String? ?? '',
        matchPercent: json['match_percent'] as int? ?? 0,
      );

  static List<String> _strings(Object? value) =>
      value is List ? value.map((v) => '$v').toList() : const [];
}

/// One hour an expert is free, as the calendar draws it.
class FreeSlot {
  const FreeSlot({required this.id, required this.day, required this.startMinute,
      required this.endMinute});

  final String id;
  final DateTime day;

  /// Minutes from midnight, which is how both sides model a slot so no
  /// timezone can shift it.
  final int startMinute;
  final int endMinute;

  /// "5:00pm", the way the calendar prints its options.
  String get label {
    final hour = startMinute ~/ 60;
    final minute = startMinute % 60;
    final display = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour < 12 ? 'am' : 'pm';
    return minute == 0
        ? '$display:00$suffix'
        : '$display:${minute.toString().padLeft(2, '0')}$suffix';
  }

  factory FreeSlot.fromJson(Map<String, dynamic> json) => FreeSlot(
        id: '${json['id']}',
        day: DateTime.tryParse('${json['day']}') ?? DateTime.now(),
        startMinute: json['start_minute'] as int? ?? 0,
        endMinute: json['end_minute'] as int? ?? 0,
      );
}
