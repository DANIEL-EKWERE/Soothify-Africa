/// A place a Passport member holds in a studio class, and the class itself.
///
/// These are the member's half of the studio flow. The same row is what the
/// studio partner sees on its roster: reserving one is what puts a guest on
/// their list, and [PassportReservation.code] is the code their front desk
/// verifies.
library;

/// One bookable session on a studio's profile.
class StudioSession {
  const StudioSession({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    this.minutes = 60,
    this.instructor = '',
    this.room = '',
    this.spotsOpen = 0,
    this.isFull = false,
  });

  final int id;
  final String title;

  /// 'reformer', 'mat' or 'yoga' — what the studio calls the class, and what
  /// the wholesale rate is read from.
  final String category;
  final DateTime startsAt;
  final int minutes;
  final String instructor;
  final String room;

  /// Passport places left. The design draws the button disabled at zero
  /// rather than hiding the class: a full class is information too.
  final int spotsOpen;
  final bool isFull;

  DateTime get endsAt => startsAt.add(Duration(minutes: minutes));

  factory StudioSession.fromJson(Map<String, dynamic> json) => StudioSession(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        startsAt:
            DateTime.tryParse('${json['starts_at']}')?.toLocal() ??
                DateTime.now(),
        minutes: json['minutes'] as int? ?? 60,
        instructor: json['instructor'] as String? ?? '',
        room: json['room'] as String? ?? '',
        spotsOpen: json['spots_open'] as int? ?? 0,
        isFull: json['is_full'] as bool? ?? false,
      );
}

/// A place held in one of those sessions.
class PassportReservation {
  const PassportReservation({
    required this.id,
    required this.className,
    required this.startsAt,
    this.sessionType = '',
    this.status = 'pending',
    this.code = '',
    this.spaceName = '',
    this.spaceArea = '',
    this.cover = '',
    this.checkedInAt,
    this.canCancel = true,
  });

  final int id;
  final String className;
  final DateTime startsAt;
  final String sessionType;

  /// 'pending', 'accepted', 'declined' or 'cancelled'. The studio accepting
  /// is an acknowledgement, not a gate — the place is held from the moment
  /// it is reserved, which is why the pass is issued straight away.
  final String status;

  /// What the front desk verifies. Six characters, no O/0 or I/1: it is read
  /// aloud across a counter as often as it is scanned.
  final String code;

  final String spaceName;
  final String spaceArea;
  final String cover;
  final DateTime? checkedInAt;
  final bool canCancel;

  bool get isCheckedIn => checkedInAt != null;

  /// The code as the pass prints it — two groups of three.
  String get codeLabel =>
      code.length == 6 ? '${code.substring(0, 3)} ${code.substring(3)}' : code;

  factory PassportReservation.fromJson(Map<String, dynamic> json) =>
      PassportReservation(
        id: json['id'] as int? ?? 0,
        className: json['class_name'] as String? ?? '',
        startsAt:
            DateTime.tryParse('${json['starts_at']}')?.toLocal() ??
                DateTime.now(),
        sessionType: json['session_type'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        code: json['code'] as String? ?? '',
        spaceName: json['space_name'] as String? ?? '',
        spaceArea: json['space_area'] as String? ?? '',
        cover: json['cover'] as String? ?? '',
        checkedInAt:
            DateTime.tryParse('${json['checked_in_at']}')?.toLocal(),
        canCancel: json['can_cancel'] as bool? ?? true,
      );
}
