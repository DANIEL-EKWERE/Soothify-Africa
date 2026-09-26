import '../../core/utils/image_constant.dart';
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
}
