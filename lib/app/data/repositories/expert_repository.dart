import '../models/bank_destination.dart';
import '../models/expert_earnings.dart';
import '../models/expert_session.dart';

/// What the expert role's screens code against.
abstract class ExpertRepository {
  /// The expert's own display name, for "Welcome back,".
  Future<String> displayName();

  /// Booked sessions, soonest first.
  Future<List<ExpertSession>> upcomingSessions();

  Future<ExpertEarnings> earnings();

  /// The accounts payouts can land in. Empty means the expert has never
  /// added one, which is what sends Withdraw to the payout-method chooser
  /// instead of to the amount screen.
  Future<List<BankDestination>> payoutDestinations();

  Future<List<AvailabilitySlot>> availability();

  Future<void> saveAvailability(List<AvailabilitySlot> slots);
}
