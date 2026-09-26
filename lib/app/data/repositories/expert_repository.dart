import '../models/expert_earnings.dart';
import '../models/expert_session.dart';

/// What the expert role's screens code against.
abstract class ExpertRepository {
  /// The expert's own display name, for "Welcome back,".
  Future<String> displayName();

  /// Booked sessions, soonest first.
  Future<List<ExpertSession>> upcomingSessions();

  Future<ExpertEarnings> earnings();

  Future<List<AvailabilitySlot>> availability();

  Future<void> saveAvailability(List<AvailabilitySlot> slots);
}
