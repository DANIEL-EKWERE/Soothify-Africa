import '../models/studio_partner.dart';
import 'partner_repository.dart';

/// The portal's data while the studio endpoints are being built.
///
/// The frames' own rows, not invented ones: two pending requests and six
/// guests of whom two are through the door, which is exactly what the
/// metrics and the filter counts say.
class MockPartnerRepository implements PartnerRepository {
  MockPartnerRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  static const _latency = Duration(milliseconds: 220);

  List<StudioBookingRequest>? _requests;
  List<StudioGuest>? _guests;

  @override
  Future<StudioOverview> overview() async {
    await Future<void>.delayed(_latency);
    final at = _now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return StudioOverview(
      studioName: 'Luma Pilates Studio',
      pending: (await requests())
          .where((r) => r.status == StudioRequestStatus.pending)
          .length,
      confirmedToday: 6,
      payoutNaira: 342000,
      payoutPeriod: '${months[at.month - 1]} ${at.year}',
    );
  }

  @override
  Future<List<StudioBookingRequest>> requests() async {
    final at = _now();
    final today = DateTime(at.year, at.month, at.day);
    return _requests ??= [
      StudioBookingRequest(
        id: '1',
        guestName: 'Rita P.',
        className: 'Reformer Flow',
        startsAt: today.add(const Duration(hours: 9)),
        sessionType: 'Reformer Session',
        payoutNaira: 21500,
        receivedAt: at,
      ),
      StudioBookingRequest(
        id: '2',
        guestName: 'Ada N.',
        className: 'Mat Pilates',
        startsAt: today.add(const Duration(hours: 10)),
        sessionType: 'Mat Session',
        payoutNaira: 12500,
        receivedAt: at.subtract(const Duration(minutes: 4)),
      ),
    ];
  }

  @override
  Future<StudioBookingRequest> accept(String requestId) =>
      _answer(requestId, StudioRequestStatus.accepted);

  @override
  Future<StudioBookingRequest> decline(String requestId) =>
      _answer(requestId, StudioRequestStatus.declined);

  Future<StudioBookingRequest> _answer(
    String id,
    StudioRequestStatus status,
  ) async {
    await Future<void>.delayed(_latency);
    final all = await requests();
    final i = all.indexWhere((r) => r.id == id);
    if (i < 0) throw StateError('no request $id');
    return all[i] = all[i].copyWith(status: status, unread: false);
  }

  @override
  Future<List<StudioGuest>> guests({DateTime? day}) async {
    await Future<void>.delayed(_latency);
    final at = day ?? _now();
    final base = DateTime(at.year, at.month, at.day, 9);
    // The frame's six, in its order: two verified, four still to arrive.
    const names = ['Dami A.', 'Timi O.', 'Amina B.', 'Chika E.', 'Tolu S.',
        'Nneka I.'];
    return _guests ??= [
      for (var i = 0; i < names.length; i++)
        StudioGuest(
          id: '${i + 1}',
          name: names[i],
          className: 'Reformer Flow',
          startsAt: base,
          code: 'LM-280${i + 1}',
          arrival: i < 2 ? StudioArrival.checkedIn : StudioArrival.awaiting,
          verifiedAt: i < 2
              ? base.subtract(Duration(minutes: 18 - i * 4))
              : null,
        ),
    ];
  }

  StudioRoster? _roster;

  @override
  Future<StudioRoster> roster(String classId) async {
    await Future<void>.delayed(_latency);
    final at = _now();
    final start = DateTime(at.year, at.month, at.day, 6);
    // The frame's own class and its three members: two through the door,
    // one not arrived — and both check-ins still waiting to sync, because
    // the frame has the offline banner up.
    return _roster ??= StudioRoster(
      classId: classId,
      title: 'Reformer Flow',
      category: StudioClassCategory.reformer,
      startsAt: start,
      endsAt: start.add(const Duration(minutes: 90)),
      instructor: 'Kemi A.',
      room: 'Studio A',
      bookings: 3,
      slotsOpen: 3,
      offline: true,
      members: [
        RosterMember(
          id: '1',
          name: 'Dami A.',
          tier: 'Pro Flow',
          status: StudioVerification.verified,
          code: 'STH-12B',
          at: start.subtract(const Duration(minutes: 12)),
          pendingSync: true,
        ),
        RosterMember(
          id: '2',
          name: 'Tomi O.',
          tier: 'Habit Builder',
          status: StudioVerification.verified,
          code: 'STH-45C',
          at: start.subtract(const Duration(minutes: 8)),
          pendingSync: true,
        ),
        const RosterMember(
          id: '3',
          name: 'Amina B.',
          tier: 'Starter Flow',
          status: StudioVerification.notArrived,
          code: 'STH-89A',
        ),
      ],
    );
  }

  @override
  Future<CheckInOutcome> verifyEntry(String classId, String code) async {
    await Future<void>.delayed(_latency);
    final roster_ = await roster(classId);
    final wanted = code.trim().toUpperCase();
    final i = roster_.members.indexWhere(
      (m) => m.code.toUpperCase() == wanted,
    );
    if (i < 0) {
      return const CheckInOutcome(
        member: null,
        problem: 'No booking matches that entry code.',
      );
    }
    final member = roster_.members[i];
    if (member.status != StudioVerification.notArrived) {
      return CheckInOutcome(
        member: member,
        problem: '${member.name} is already checked in.',
      );
    }
    // The frame's error state: this one code has expired, which is what
    // sends the desk to the dispute dialog.
    if (wanted == 'STH-89A') {
      return CheckInOutcome(
        member: member,
        problem: 'This entry code has expired. Try again or grant '
            'provisional entry so the member can join class.',
      );
    }
    final admitted = member.copyWith(
      status: StudioVerification.verified,
      at: _now(),
      pendingSync: true,
    );
    _replace(admitted);
    return CheckInOutcome(member: admitted);
  }

  @override
  Future<RosterMember> grantProvisional(
    String classId,
    String memberId, {
    required List<CheckInProblem> problems,
  }) async {
    await Future<void>.delayed(_latency);
    final roster_ = await roster(classId);
    final member = roster_.members.firstWhere((m) => m.id == memberId);
    final granted = member.copyWith(
      status: StudioVerification.provisional,
      at: _now(),
      pendingSync: true,
    );
    _replace(granted);
    return granted;
  }

  void _replace(RosterMember member) {
    final was = _roster!;
    final members = [...was.members];
    final i = members.indexWhere((m) => m.id == member.id);
    if (i >= 0) members[i] = member;
    _roster = was.withMembers(members);
  }

  List<StudioClassSlot>? _classes;

  @override
  Future<StudioSchedule> schedule({DateTime? week}) async {
    await Future<void>.delayed(_latency);
    final at = week ?? _now();
    // The grid opens on a Monday, whichever day was asked for.
    final monday = DateTime(at.year, at.month, at.day)
        .subtract(Duration(days: (at.weekday - DateTime.monday) % 7));

    StudioClassSlot slot(
      int id,
      int day,
      int hour,
      String title,
      StudioClassCategory category,
      String instructor,
      String room,
      int open,
    ) =>
        StudioClassSlot(
          id: '$id',
          title: title,
          category: category,
          startsAt: monday.add(Duration(days: day, hours: hour)),
          minutes: 90,
          instructor: instructor,
          room: room,
          passportOpen: open,
          passportTotal: 3,
        );

    // The frame's own eight, on its own days and hours.
    _classes ??= [
      slot(1, 0, 6, 'Reformer Flow', StudioClassCategory.reformer, 'Kemi A.',
          'Studio A', 3),
      slot(2, 0, 12, 'Midday Yoga', StudioClassCategory.yoga, 'Sade O.',
          'Studio B', 2),
      slot(3, 1, 8, 'Mat Foundations', StudioClassCategory.mat, 'Ada N.',
          'Studio B', 3),
      slot(4, 1, 17, 'Reformer Sculpt', StudioClassCategory.reformer,
          'Kemi A.', 'Studio A', 0),
      slot(5, 2, 9, 'Morning Yoga', StudioClassCategory.yoga, 'Sade O.',
          'Studio B', 0),
      slot(6, 3, 10, 'Mat Flow', StudioClassCategory.mat, 'Ada N.',
          'Studio B', 0),
      slot(7, 4, 18, 'Reformer Flow', StudioClassCategory.reformer, 'Kemi A.',
          'Studio A', 0),
      slot(8, 5, 8, 'Weekend Yoga', StudioClassCategory.yoga, 'Sade O.',
          'Studio B', 0),
    ];

    final open = _classes!.fold(0, (sum, c) => sum + c.passportOpen);
    final total = _classes!.fold(0, (sum, c) => sum + c.passportTotal);
    return StudioSchedule(
      weekStart: monday,
      weekNumber: _weekOf(monday),
      slotsOpen: open,
      passportBookings: total - open,
      utilisation: total == 0 ? 0 : ((total - open) * 100 / total).round(),
      classes: _classes!,
    );
  }

  @override
  Future<StudioClassSlot> addSlot(StudioClassSlot slot) async {
    await Future<void>.delayed(_latency);
    await schedule();
    final added = StudioClassSlot(
      id: '${_classes!.length + 1}',
      title: slot.title,
      category: slot.category,
      startsAt: slot.startsAt,
      minutes: slot.minutes,
      instructor: slot.instructor,
      room: slot.room,
      passportOpen: slot.passportTotal,
      passportTotal: slot.passportTotal,
    );
    _classes!.add(added);
    return added;
  }

  /// ISO week, which is what "WEEK 49" is.
  static int _weekOf(DateTime day) {
    final thursday = day.add(Duration(days: 4 - ((day.weekday + 6) % 7 + 1)));
    final firstJan = DateTime(thursday.year, 1, 1);
    return ((thursday.difference(firstJan).inDays) / 7).floor() + 1;
  }

  List<StudioEarning>? _earnings;

  @override
  Future<StudioLedger> ledger({DateTime? month}) async {
    await Future<void>.delayed(_latency);
    final at = month ?? _now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    // The frame's own four lines: two queued from the 28th, two already
    // disbursed from the 14th, and only the newest still disputable.
    _earnings ??= [
      StudioEarning(
        id: '1',
        guestName: 'Dami A.',
        category: 'Reformer',
        earnedOn: DateTime(at.year, at.month, 28),
        payoutNaira: 21500,
        status: StudioEarningStatus.queued,
        disputable: true,
      ),
      StudioEarning(
        id: '2',
        guestName: 'Tomi O.',
        category: 'Mat',
        earnedOn: DateTime(at.year, at.month, 28),
        payoutNaira: 12500,
        status: StudioEarningStatus.queued,
      ),
      StudioEarning(
        id: '3',
        guestName: 'Amina B.',
        category: 'Yoga',
        earnedOn: DateTime(at.year, at.month, 14),
        payoutNaira: 10000,
        status: StudioEarningStatus.disbursed,
      ),
      StudioEarning(
        id: '4',
        guestName: 'Chika E.',
        category: 'Reformer',
        earnedOn: DateTime(at.year, at.month, 14),
        payoutNaira: 21500,
        status: StudioEarningStatus.disbursed,
      ),
    ];
    return StudioLedger(
      accruedNaira: 342000,
      // "Every 1st & 15th" — whichever comes next.
      nextDisbursement: at.day < 15
          ? DateTime(at.year, at.month, 15)
          : DateTime(at.year, at.month + 1, 1),
      lifetimeNaira: 2184500,
      period: '${months[at.month - 1]} ${at.year}',
      totalEarnings: 24,
      earnings: _earnings!,
    );
  }

  @override
  Future<StudioEarning> dispute(String earningId, {String reason = ''}) async {
    await Future<void>.delayed(_latency);
    await ledger();
    final all = _earnings!;
    final i = all.indexWhere((e) => e.id == earningId);
    if (i < 0) throw StateError('no earning $earningId');
    final was = all[i];
    return all[i] = StudioEarning(
      id: was.id,
      guestName: was.guestName,
      category: was.category,
      earnedOn: was.earnedOn,
      payoutNaira: was.payoutNaira,
      status: StudioEarningStatus.disputed,
    );
  }

  @override
  Future<StudioGuest> checkIn(String guestId, {String code = ''}) async {
    await Future<void>.delayed(_latency);
    final all = await guests();
    final i = all.indexWhere((g) => g.id == guestId);
    if (i < 0) throw StateError('no guest $guestId');
    return all[i] = all[i].copyWith(
      arrival: StudioArrival.checkedIn,
      verifiedAt: _now(),
    );
  }
}
