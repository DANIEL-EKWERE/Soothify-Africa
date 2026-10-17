import '../../core/utils/image_constant.dart';
import '../models/bank_destination.dart';
import '../models/bank_option.dart';
import '../models/expert_earnings.dart';
import '../models/expert_session.dart';
import 'expert_repository.dart';

/// The expert screens' data while there is no backend.
///
/// Deliberately the frames' own rows rather than invented ones: the design
/// repeats "Dami / Timi / Amina" and one time range across every card, and a
/// richer mock would make the screens look finished when they are not.
class MockExpertRepository implements ExpertRepository {
  MockExpertRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  static const _latency = Duration(milliseconds: 220);

  @override
  Future<String> displayName() async {
    await Future<void>.delayed(_latency);
    // The same name the coach carries on the client side.
    return 'Baraqhat';
  }

  @override
  Future<List<ExpertSession>> upcomingSessions() async {
    await Future<void>.delayed(_latency);
    final n = _now();
    final today = DateTime(n.year, n.month, n.day, 10);
    const clients = [
      ('Dami', '1-on-1 Therapy', ImageConstant.imgAvatarFemale),
      ('Timi', '1-on-1 Therapy', ImageConstant.imgAvatarMale),
      ('Amina', 'Pilates', ImageConstant.imgAvatarFemale),
      ('Amina', 'Pilates', ImageConstant.imgAvatarFemale),
      ('Amina', 'Pilates', ImageConstant.imgAvatarFemale),
      ('Amina', 'Pilates', ImageConstant.imgAvatarFemale),
    ];
    return [
      for (var i = 0; i < clients.length; i++)
        ExpertSession(
          id: '${i + 1}',
          clientName: clients[i].$1,
          service: clients[i].$2,
          avatarAsset: clients[i].$3,
          startsAt: today.add(Duration(minutes: 60 * i)),
          endsAt: today.add(Duration(minutes: 60 * i + 30)),
        ),
    ];
  }

  @override
  Future<ExpertEarnings> earnings() async {
    await Future<void>.delayed(_latency);
    return ExpertEarnings.sample(now: _now);
  }

  /// Seeded with the one account the frames show saved — the "Payout method"
  /// card's Access Bank row. Held in memory, so anything added during a run
  /// lasts as long as the run.
  List<BankDestination>? _destinations;

  @override
  Future<List<BankDestination>> payoutDestinations() async {
    await Future<void>.delayed(_latency);
    return _destinations ??= const [
      BankDestination(
        bank: 'Access Bank',
        accountNumber: '0234 5678 890',
        accountName: 'Baraqhat Ibrahim',
      ),
    ];
  }

  List<AvailabilitySlot>? _slots;

  @override
  Future<List<AvailabilitySlot>> availability() async {
    await Future<void>.delayed(_latency);
    final n = _now();
    // The frame draws five identical rows: Monday, Sep 28, 9am - 10 am.
    return _slots ??= [
      for (var i = 0; i < 5; i++)
        AvailabilitySlot(
          id: '${i + 1}',
          day: DateTime(n.year, n.month, n.day).add(Duration(days: 7 * i)),
          from: 9 * 60,
          to: 10 * 60,
        ),
    ];
  }

  /// Held in memory only. Nothing persists an expert's calendar yet, and
  /// writing it to preferences would imply clients can see it.
  @override
  Future<void> saveAvailability(List<AvailabilitySlot> slots) async {
    await Future<void>.delayed(_latency);
    _slots = List.of(slots);
  }

  @override
  Future<BankDestination> addPayoutDestination({
    required String bankName,
    required String bankCode,
    required String accountNumber,
  }) async {
    // Through the getter, because the seeded list is a const one and the
    // field starts null.
    final current = await payoutDestinations();
    // The name is the one that was typed -- with a server it is the bank's
    // own answer, which is the point of asking them.
    final added = BankDestination(
      bank: bankName,
      accountNumber: accountNumber,
      accountName: 'Account holder',
    );
    _destinations = [...current, added];
    return added;
  }

  @override
  Future<List<BankOption>> banks() async {
    await Future<void>.delayed(_latency);
    // The handful the frame's picker drew. With a server this is Bachs'
    // own list, codes included.
    return const [
      BankOption(code: '044', name: 'Access Bank'),
      BankOption(code: '058', name: 'Guaranty Trust Bank'),
      BankOption(code: '011', name: 'First Bank of Nigeria'),
      BankOption(code: '033', name: 'United Bank for Africa'),
      BankOption(code: '057', name: 'Zenith Bank'),
      BankOption(code: '50211', name: 'Kuda Bank'),
      BankOption(code: '999992', name: 'Opay'),
    ];
  }

  @override
  Future<void> requestPayout(int naira) async {
    await Future<void>.delayed(_latency);
    // Nothing is owed and nothing is sent. Saying otherwise would be the
    // one lie a payout screen must never tell.
  }

  @override
  Future<AvailabilitySlot> addAvailability({
    required DateTime day,
    required int from,
    required int to,
  }) async {
    final current = await availability();
    final slot = AvailabilitySlot(
      id: 'mock-${DateTime.now().microsecondsSinceEpoch}',
      day: day,
      from: from,
      to: to,
    );
    _slots = [...current, slot];
    return slot;
  }

  @override
  Future<void> removeAvailability(String id) async {
    final current = await availability();
    _slots = current.where((slot) => slot.id != id).toList();
  }

  @override
  Future<String> sessionNote(String sessionId) async {
    await Future<void>.delayed(_latency);
    return _notes[sessionId] ?? '';
  }

  @override
  Future<void> saveSessionNote(String sessionId, String body) async {
    await Future<void>.delayed(_latency);
    _notes[sessionId] = body;
  }

  final Map<String, String> _notes = <String, String>{};
}
