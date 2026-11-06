import '../models/studio_partner.dart';

/// The Studio Partner portal's data — Figma `4968:32935` and `4968:32751`.
///
/// A studio answers booking requests and works the door; nothing else in
/// the app reads these, which is why they are their own repository rather
/// than more methods on the spaces one.
abstract class PartnerRepository {
  /// The three figures across the top of both frames.
  Future<StudioOverview> overview();

  /// What is waiting to be answered, newest first.
  Future<List<StudioBookingRequest>> requests();

  /// Take the booking. The studio is committing its floor, so the answer is
  /// the request as the server now holds it rather than a bare success.
  Future<StudioBookingRequest> accept(String requestId);

  Future<StudioBookingRequest> decline(String requestId);

  /// Who is expected today. [day] defaults to today on the server.
  Future<List<StudioGuest>> guests({DateTime? day});

  /// The door scanned a guest's QR.
  Future<StudioGuest> checkIn(String guestId, {String code = ''});

  /// The door's view of one class — Figma `416:26667`.
  Future<StudioRoster> roster(String classId);

  /// Verify a member's entry code or QR. A failure is an answer, not an
  /// error: the desk is told why and offered provisional entry.
  Future<CheckInOutcome> verifyEntry(String classId, String code);

  /// Let somebody in anyway, with a report to the admin log — Figma
  /// `416:26781`.
  Future<RosterMember> grantProvisional(
    String classId,
    String memberId, {
    required List<CheckInProblem> problems,
  });

  /// A week of the master schedule — Figma `416:26376`. [week] is any day
  /// in the week wanted; the server answers with its Monday.
  Future<StudioSchedule> schedule({DateTime? week});

  /// Put a Passport class on the timetable — Figma `416:26557`.
  Future<StudioClassSlot> addSlot(StudioClassSlot slot);

  /// "Financials & Settlement Hub" — Figma `416:26282`. [month] defaults to
  /// the current one on the server.
  Future<StudioLedger> ledger({DateTime? month});

  /// The studio says a check-in was wrong. The line comes back as the
  /// server now holds it, which is what takes it out of the next
  /// settlement.
  Future<StudioEarning> dispute(String earningId, {String reason = ''});
}
