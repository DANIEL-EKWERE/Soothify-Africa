import '../models/bank_destination.dart';
import '../models/bank_option.dart';
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

  /// Adds one. The number goes to the provider, which confirms the name on
  /// the account and makes a destination of it; what comes back carries only
  /// the last four digits, because that is all that is kept.
  Future<BankDestination> addPayoutDestination({
    required String bankName,
    required String bankCode,
    required String accountNumber,
  });

  /// The banks to choose from, with the codes the account lookup needs.
  Future<List<BankOption>> banks();

  /// Asks to be paid. The request is recorded and a person sends the money,
  /// so nothing here may tell the expert it has arrived.
  Future<void> requestPayout(int naira);

  Future<List<AvailabilitySlot>> availability();

  /// Replaces the week: hours missing from [slots] are closed, and hours in
  /// it without an id are opened.
  Future<void> saveAvailability(List<AvailabilitySlot> slots);

  /// Opens one hour. Returns it carrying the id the server gave it, which is
  /// what closing it again needs.
  Future<AvailabilitySlot> addAvailability({
    required DateTime day,
    required int from,
    required int to,
  });

  /// Closes one.
  Future<void> removeAvailability(String id);

  /// The practitioner's own note on a session. Empty when there is none.
  ///
  /// Never served to the client — these are clinical notes, and the server
  /// enforces that as firmly as this app does.
  Future<String> sessionNote(String sessionId);

  Future<void> saveSessionNote(String sessionId, String body);
}
