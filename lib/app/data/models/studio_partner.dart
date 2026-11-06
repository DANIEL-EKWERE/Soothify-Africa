/// The Studio Partner portal's data — Figma "Studio partner portal ·
/// Overview" (`4968:32935`) and "· Active Guest List" (`4968:32751`).
///
/// A third role beside the client and the practitioner: the studio whose
/// floor a Passport member books. The portal does two things — answer
/// booking requests, and work the door on the day.
library;

/// Where a request has got to. The frames draw only the pending state, but
/// the two buttons under it say what the other two are.
enum StudioRequestStatus {
  pending('Pending Acceptance'),
  accepted('Accepted'),
  declined('Declined');

  const StudioRequestStatus(this.label);

  final String label;
}

/// One "New Booking Request!" card.
class StudioBookingRequest {
  const StudioBookingRequest({
    required this.id,
    required this.guestName,
    required this.className,
    required this.startsAt,
    required this.sessionType,
    required this.payoutNaira,
    required this.receivedAt,
    this.status = StudioRequestStatus.pending,
    this.unread = true,
  });

  final String id;

  /// "Rita P." — a first name and an initial, as the frame writes it.
  final String guestName;

  /// "Reformer Flow".
  final String className;

  final DateTime startsAt;

  /// "Reformer Session" — what the floor is being paid for.
  final String sessionType;

  /// The wholesale floor payout, which is what the studio actually earns.
  final int payoutNaira;

  final DateTime receivedAt;

  final StudioRequestStatus status;

  /// The blue dot at the card's top right.
  final bool unread;

  /// "Accept & Reserve Mat" — the frame names the thing being reserved.
  String get acceptLabel => 'Accept & Reserve '
      '${sessionType.toLowerCase().contains('reformer') ? 'Reformer' : 'Mat'}';

  StudioBookingRequest copyWith({StudioRequestStatus? status, bool? unread}) =>
      StudioBookingRequest(
        id: id,
        guestName: guestName,
        className: className,
        startsAt: startsAt,
        sessionType: sessionType,
        payoutNaira: payoutNaira,
        receivedAt: receivedAt,
        status: status ?? this.status,
        unread: unread ?? this.unread,
      );

  factory StudioBookingRequest.fromJson(Map<String, dynamic> json) =>
      StudioBookingRequest(
        id: '${json['id']}',
        guestName: json['guest_name'] as String? ?? '',
        className: json['class_name'] as String? ?? '',
        startsAt: DateTime.tryParse('${json['starts_at']}')?.toLocal() ??
            DateTime.now(),
        sessionType: json['session_type'] as String? ?? '',
        payoutNaira: json['payout_naira'] as int? ?? 0,
        receivedAt: DateTime.tryParse('${json['received_at']}')?.toLocal() ??
            DateTime.now(),
        status: switch (json['status'] as String?) {
          'accepted' => StudioRequestStatus.accepted,
          'declined' => StudioRequestStatus.declined,
          _ => StudioRequestStatus.pending,
        },
        unread: json['unread'] as bool? ?? true,
      );
}

/// Whether the guest is through the door.
enum StudioArrival {
  checkedIn('Checked In'),
  awaiting('Awaiting Arrival');

  const StudioArrival(this.label);

  final String label;
}

/// One row of "Today's Guests".
class StudioGuest {
  const StudioGuest({
    required this.id,
    required this.name,
    required this.className,
    required this.startsAt,
    required this.code,
    required this.arrival,
    this.verifiedAt,
  });

  final String id;

  /// "Dami A."
  final String name;
  final String className;
  final DateTime startsAt;

  /// "LM-2801" — the booking id the door reads off the guest's QR.
  final String code;

  final StudioArrival arrival;

  /// When the QR was scanned. Null until it is — the frame then prints
  /// "QR generated" instead of "QR verified · 8:42 AM".
  final DateTime? verifiedAt;

  /// "DA" — the avatar's initials.
  String get initials {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.map((p) => p[0].toUpperCase()).take(2).join();
  }

  StudioGuest copyWith({StudioArrival? arrival, DateTime? verifiedAt}) =>
      StudioGuest(
        id: id,
        name: name,
        className: className,
        startsAt: startsAt,
        code: code,
        arrival: arrival ?? this.arrival,
        verifiedAt: verifiedAt ?? this.verifiedAt,
      );

  factory StudioGuest.fromJson(Map<String, dynamic> json) => StudioGuest(
        id: '${json['id']}',
        name: json['guest_name'] as String? ?? '',
        className: json['class_name'] as String? ?? '',
        startsAt: DateTime.tryParse('${json['starts_at']}')?.toLocal() ??
            DateTime.now(),
        code: json['code'] as String? ?? '',
        arrival: json['checked_in_at'] == null
            ? StudioArrival.awaiting
            : StudioArrival.checkedIn,
        verifiedAt: DateTime.tryParse('${json['checked_in_at']}')?.toLocal(),
      );
}

/// The three figures across the top of both frames.
class StudioOverview {
  const StudioOverview({
    required this.studioName,
    required this.pending,
    required this.confirmedToday,
    required this.payoutNaira,
    required this.payoutPeriod,
  });

  final String studioName;
  final int pending;
  final int confirmedToday;

  /// What has accrued this month — the studio's, not Soothify's.
  final int payoutNaira;

  /// "November 2026".
  final String payoutPeriod;

  factory StudioOverview.fromJson(Map<String, dynamic> json) => StudioOverview(
        studioName: json['studio_name'] as String? ?? '',
        pending: json['pending'] as int? ?? 0,
        confirmedToday: json['confirmed_today'] as int? ?? 0,
        payoutNaira: json['payout_naira'] as int? ?? 0,
        payoutPeriod: json['payout_period'] as String? ?? '',
      );
}

/// Where a line of the ledger has got to — Figma "4.2 · Studio payout
/// ledger" (`416:26282`).
enum StudioEarningStatus {
  /// Checked in and counted, waiting for the next settlement.
  queued('Verified & Queued'),

  /// Paid out.
  disbursed('Disbursed'),

  /// The studio said the check-in was wrong, and it is being looked at.
  disputed('Disputed');

  const StudioEarningStatus(this.label);

  final String label;
}

/// One line of the ledger: a verified check-in and what the floor earned
/// for it.
class StudioEarning {
  const StudioEarning({
    required this.id,
    required this.guestName,
    required this.category,
    required this.earnedOn,
    required this.payoutNaira,
    required this.status,
    this.disputable = false,
  });

  final String id;
  final String guestName;

  /// "Reformer", "Mat", "Yoga" — the frame prints "Class category · X".
  final String category;

  final DateTime earnedOn;
  final int payoutNaira;
  final StudioEarningStatus status;

  /// Whether "Dispute Check-In" shows. The frame draws it on the newest
  /// line only: a settled fortnight is closed, which is what the footnote
  /// under the table says.
  final bool disputable;

  factory StudioEarning.fromJson(Map<String, dynamic> json) => StudioEarning(
        id: '${json['id']}',
        guestName: json['guest_name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        earnedOn: DateTime.tryParse('${json['earned_on']}')?.toLocal() ??
            DateTime.now(),
        payoutNaira: json['payout_naira'] as int? ?? 0,
        status: switch (json['status'] as String?) {
          'disbursed' => StudioEarningStatus.disbursed,
          'disputed' => StudioEarningStatus.disputed,
          _ => StudioEarningStatus.queued,
        },
        disputable: json['disputable'] as bool? ?? false,
      );
}

/// The figures above the ledger table.
class StudioLedger {
  const StudioLedger({
    required this.accruedNaira,
    required this.nextDisbursement,
    required this.lifetimeNaira,
    required this.period,
    required this.totalEarnings,
    required this.earnings,
  });

  /// "Accrued Unpaid Balance" — queued for the next settlement.
  final int accruedNaira;

  final DateTime nextDisbursement;
  final int lifetimeNaira;

  /// Which month the table is showing — "November 2026".
  final String period;

  /// How many lines exist behind the handful shown.
  final int totalEarnings;

  final List<StudioEarning> earnings;

  factory StudioLedger.fromJson(Map<String, dynamic> json) => StudioLedger(
        accruedNaira: json['accrued_naira'] as int? ?? 0,
        nextDisbursement:
            DateTime.tryParse('${json['next_disbursement']}')?.toLocal() ??
                DateTime.now(),
        lifetimeNaira: json['lifetime_naira'] as int? ?? 0,
        period: json['period'] as String? ?? '',
        totalEarnings: json['total'] as int? ?? 0,
        earnings: [
          for (final row in (json['earnings'] as List? ?? const []))
            StudioEarning.fromJson(row as Map<String, dynamic>),
        ],
      );
}

/// What a Passport class is — Figma "5.1 · Master schedule & Sōōthify
/// slots" (`416:26376`). The legend names three, and each colours its own
/// block on the grid.
enum StudioClassCategory {
  reformer('Reformer'),
  mat('Mat'),
  yoga('Yoga');

  const StudioClassCategory(this.label);

  final String label;

  static StudioClassCategory parse(String? key) => switch (key) {
        'mat' => StudioClassCategory.mat,
        'yoga' => StudioClassCategory.yoga,
        _ => StudioClassCategory.reformer,
      };
}

/// One class on the master schedule.
///
/// Only classes with Passport allocations appear — the footnote under the
/// grid says so, and a studio's own private timetable is not Soothify's to
/// show.
class StudioClassSlot {
  const StudioClassSlot({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.minutes,
    required this.instructor,
    required this.room,
    required this.passportOpen,
    required this.passportTotal,
  });

  final String id;
  final String title;
  final StudioClassCategory category;
  final DateTime startsAt;

  /// "90 min".
  final int minutes;

  /// "Kemi A."
  final String instructor;

  /// "Studio A".
  final String room;

  /// How many Passport places are left.
  final int passportOpen;

  /// How many the studio allocated in the first place.
  final int passportTotal;

  bool get isFull => passportOpen <= 0;

  /// "3 Passport Slots Open" / "Passport slots full".
  String get availability =>
      isFull ? 'Passport slots full' : '$passportOpen Passport Slots Open';

  /// "6:00 AM · 90 min".
  String get when {
    final hour = startsAt.hour % 12 == 0 ? 12 : startsAt.hour % 12;
    final minute = startsAt.minute.toString().padLeft(2, '0');
    final meridiem = startsAt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $meridiem · $minutes min';
  }

  factory StudioClassSlot.fromJson(Map<String, dynamic> json) =>
      StudioClassSlot(
        id: '${json['id']}',
        title: json['title'] as String? ?? '',
        category: StudioClassCategory.parse(json['category'] as String?),
        startsAt: DateTime.tryParse('${json['starts_at']}')?.toLocal() ??
            DateTime.now(),
        minutes: json['minutes'] as int? ?? 60,
        instructor: json['instructor'] as String? ?? '',
        room: json['room'] as String? ?? '',
        passportOpen: json['passport_open'] as int? ?? 0,
        passportTotal: json['passport_total'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category.name,
        'starts_at': startsAt.toUtc().toIso8601String(),
        'minutes': minutes,
        'instructor': instructor,
        'room': room,
        'passport_total': passportTotal,
      };
}

/// A week of the master schedule, with the three figures above it.
class StudioSchedule {
  const StudioSchedule({
    required this.weekStart,
    required this.weekNumber,
    required this.slotsOpen,
    required this.passportBookings,
    required this.utilisation,
    required this.classes,
  });

  /// The Monday the grid opens on.
  final DateTime weekStart;

  /// "WEEK 49".
  final int weekNumber;

  /// "Sōōthify Slots Open".
  final int slotsOpen;
  final int passportBookings;

  /// 0–100, printed as "60%".
  final int utilisation;

  final List<StudioClassSlot> classes;

  factory StudioSchedule.fromJson(Map<String, dynamic> json) =>
      StudioSchedule(
        weekStart: DateTime.tryParse('${json['week_start']}')?.toLocal() ??
            DateTime.now(),
        weekNumber: json['week_number'] as int? ?? 0,
        slotsOpen: json['slots_open'] as int? ?? 0,
        passportBookings: json['passport_bookings'] as int? ?? 0,
        utilisation: json['utilisation'] as int? ?? 0,
        classes: [
          for (final row in (json['classes'] as List? ?? const []))
            StudioClassSlot.fromJson(row as Map<String, dynamic>),
        ],
      );
}

/// How a member got through the door — Figma "5.3 · Live roster &
/// verification" (`416:26667`) and "5.6 · Provisionally verified roster"
/// (`416:26850`).
enum StudioVerification {
  /// Code or QR checked out.
  verified('Checked In'),

  /// Expected, not here yet.
  notArrived('Not Arrived'),

  /// Let in despite a failed check, with a report sent to the admin log.
  provisional('Provisionally Verified');

  const StudioVerification(this.label);

  final String label;

  static StudioVerification parse(String? key) => switch (key) {
        'verified' => StudioVerification.verified,
        'provisional' => StudioVerification.provisional,
        _ => StudioVerification.notArrived,
      };
}

/// One row of the live roster.
class RosterMember {
  const RosterMember({
    required this.id,
    required this.name,
    required this.tier,
    required this.status,
    this.code = '',
    this.at,
    this.pendingSync = false,
  });

  final String id;
  final String name;

  /// Which Passport tier they hold — "Pro Flow", "Starter Flow".
  final String tier;

  final StudioVerification status;

  /// "STH-89A" — what the front desk types when the camera fails.
  final String code;

  /// When they came through.
  final DateTime? at;

  /// Saved on this device and not yet filed with the server.
  final bool pendingSync;

  RosterMember copyWith({
    StudioVerification? status,
    DateTime? at,
    bool? pendingSync,
  }) =>
      RosterMember(
        id: id,
        name: name,
        tier: tier,
        status: status ?? this.status,
        code: code,
        at: at ?? this.at,
        pendingSync: pendingSync ?? this.pendingSync,
      );

  factory RosterMember.fromJson(Map<String, dynamic> json) => RosterMember(
        id: '${json['id']}',
        name: json['member_name'] as String? ?? '',
        tier: json['tier'] as String? ?? '',
        status: StudioVerification.parse(json['status'] as String?),
        code: json['code'] as String? ?? '',
        at: DateTime.tryParse('${json['verified_at']}')?.toLocal(),
        pendingSync: json['pending_sync'] as bool? ?? false,
      );
}

/// The class the door is working, and everyone booked onto it.
class StudioRoster {
  const StudioRoster({
    required this.classId,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.endsAt,
    required this.instructor,
    required this.room,
    required this.bookings,
    required this.slotsOpen,
    required this.members,
    this.offline = false,
  });

  final String classId;
  final String title;
  final StudioClassCategory category;
  final DateTime startsAt;
  final DateTime endsAt;
  final String instructor;
  final String room;

  /// "3 Passport bookings".
  final int bookings;

  /// "3 slots open".
  final int slotsOpen;

  final List<RosterMember> members;

  /// Whether the door is working without a network. The frame puts a
  /// banner up and keeps taking check-ins.
  final bool offline;

  int get verified =>
      members.where((m) => m.status == StudioVerification.verified).length;

  int get provisional =>
      members.where((m) => m.status == StudioVerification.provisional).length;

  int get admitted => verified + provisional;

  int get notArrived => members.length - admitted;

  /// "2 check-ins saved on this device · Pending sync".
  int get unsynced => members.where((m) => m.pendingSync).length;

  /// "Mon, 30 Nov 2026 · 6:00–7:30 AM".
  String get when {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    String clock(DateTime t, {bool meridiem = false}) {
      final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute${meridiem ? ' ${t.hour < 12 ? 'AM' : 'PM'}' : ''}';
    }

    return '${days[startsAt.weekday - 1]}, ${startsAt.day} '
        '${months[startsAt.month - 1]} ${startsAt.year} · '
        '${clock(startsAt)}–${clock(endsAt, meridiem: true)}';
  }

  StudioRoster withMembers(List<RosterMember> updated) => StudioRoster(
        classId: classId,
        title: title,
        category: category,
        startsAt: startsAt,
        endsAt: endsAt,
        instructor: instructor,
        room: room,
        bookings: bookings,
        slotsOpen: slotsOpen,
        members: updated,
        offline: offline,
      );

  factory StudioRoster.fromJson(Map<String, dynamic> json) => StudioRoster(
        classId: '${json['class_id']}',
        title: json['title'] as String? ?? '',
        category: StudioClassCategory.parse(json['category'] as String?),
        startsAt: DateTime.tryParse('${json['starts_at']}')?.toLocal() ??
            DateTime.now(),
        endsAt: DateTime.tryParse('${json['ends_at']}')?.toLocal() ??
            DateTime.now(),
        instructor: json['instructor'] as String? ?? '',
        room: json['room'] as String? ?? '',
        bookings: json['bookings'] as int? ?? 0,
        slotsOpen: json['slots_open'] as int? ?? 0,
        offline: false,
        members: [
          for (final row in (json['members'] as List? ?? const []))
            RosterMember.fromJson(row as Map<String, dynamic>),
        ],
      );
}

/// Why a check-in failed, and what the desk may say about it — Figma "5.5 ·
/// Dispute check-in modal" (`416:26781`).
enum CheckInProblem {
  scanner('Scanner Error'),
  code('Code Not Working'),
  other('Something Else Went Wrong');

  const CheckInProblem(this.label);

  final String label;
}

/// What came back from trying to admit somebody.
class CheckInOutcome {
  const CheckInOutcome({required this.member, this.problem = ''});

  /// Null when no booking matches the code at all.
  final RosterMember? member;

  /// Empty when it worked. "This entry code has expired." otherwise.
  final String problem;

  bool get ok => problem.isEmpty && member != null;
}
