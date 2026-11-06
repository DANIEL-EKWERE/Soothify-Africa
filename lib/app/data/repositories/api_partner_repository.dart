import '../../core/network/api_client.dart';
import '../models/studio_partner.dart';
import 'partner_repository.dart';

/// The Studio Partner portal, against the Django API.
///
/// Under `/partner/`, and everything is scoped to the studio the signed-in
/// partner manages — the app never names a studio, because a partner who
/// could pass one would be able to read another's door list.
class ApiPartnerRepository implements PartnerRepository {
  const ApiPartnerRepository(this._api);

  final ApiClient _api;

  @override
  Future<StudioOverview> overview() async =>
      StudioOverview.fromJson(await _api.get('/partner/overview/'));

  @override
  Future<List<StudioBookingRequest>> requests() async {
    final rows = await _api.getList('/partner/requests/');
    return rows.map(StudioBookingRequest.fromJson).toList();
  }

  @override
  Future<StudioBookingRequest> accept(String requestId) async =>
      StudioBookingRequest.fromJson(
        await _api.post('/partner/requests/$requestId/accept/'),
      );

  @override
  Future<StudioBookingRequest> decline(String requestId) async =>
      StudioBookingRequest.fromJson(
        await _api.post('/partner/requests/$requestId/decline/'),
      );

  @override
  Future<List<StudioGuest>> guests({DateTime? day}) async {
    final on = day == null
        ? ''
        : '?day=${day.year}-${day.month.toString().padLeft(2, '0')}'
            '-${day.day.toString().padLeft(2, '0')}';
    final rows = await _api.getList('/partner/guests/$on');
    return rows.map(StudioGuest.fromJson).toList();
  }

  @override
  Future<StudioRoster> roster(String classId) async =>
      StudioRoster.fromJson(await _api.get('/partner/classes/$classId/roster/'));

  @override
  Future<CheckInOutcome> verifyEntry(String classId, String code) async {
    final body = await _api.post(
      '/partner/classes/$classId/verify/',
      body: {'code': code},
    );
    final row = body['member'];
    return CheckInOutcome(
      member: row is Map<String, dynamic>
          ? RosterMember.fromJson(row)
          : null,
      problem: body['problem'] as String? ?? '',
    );
  }

  @override
  Future<RosterMember> grantProvisional(
    String classId,
    String memberId, {
    required List<CheckInProblem> problems,
  }) async =>
      RosterMember.fromJson(
        await _api.post(
          '/partner/classes/$classId/members/$memberId/provisional/',
          body: {'reasons': [for (final p in problems) p.name]},
        ),
      );

  @override
  Future<StudioSchedule> schedule({DateTime? week}) async {
    final on = week == null
        ? ''
        : '?week=${week.year}-${week.month.toString().padLeft(2, '0')}'
            '-${week.day.toString().padLeft(2, '0')}';
    return StudioSchedule.fromJson(await _api.get('/partner/schedule/$on'));
  }

  @override
  Future<StudioClassSlot> addSlot(StudioClassSlot slot) async =>
      StudioClassSlot.fromJson(
        await _api.post('/partner/schedule/', body: slot.toJson()),
      );

  @override
  Future<StudioLedger> ledger({DateTime? month}) async {
    final on = month == null
        ? ''
        : '?month=${month.year}-${month.month.toString().padLeft(2, '0')}';
    return StudioLedger.fromJson(await _api.get('/partner/ledger/$on'));
  }

  @override
  Future<StudioEarning> dispute(String earningId, {String reason = ''}) async =>
      StudioEarning.fromJson(
        await _api.post(
          '/partner/earnings/$earningId/dispute/',
          body: {if (reason.isNotEmpty) 'reason': reason},
        ),
      );

  @override
  Future<StudioGuest> checkIn(String guestId, {String code = ''}) async =>
      StudioGuest.fromJson(
        await _api.post(
          '/partner/guests/$guestId/check-in/',
          body: {if (code.isNotEmpty) 'code': code},
        ),
      );
}
