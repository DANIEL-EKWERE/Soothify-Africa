import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/image_constant.dart';
import '../models/bank_destination.dart';
import '../models/bank_option.dart';
import '../models/expert_earnings.dart';
import '../models/expert_session.dart';
import 'expert_repository.dart';

/// The practitioner's own screens, against `/api/v1/experts/me/`.
///
/// Every path here is guarded server-side by the practitioner role, so a
/// client account reaching one gets a 403 rather than an empty dashboard —
/// which is the right way round: an empty dashboard looks like a bug.
class ApiExpertRepository implements ExpertRepository {
  ApiExpertRepository(this._api);

  final ApiClient _api;

  @override
  Future<String> displayName() async {
    final me = await _api.get('/auth/me/');
    final name = me['full_name'] as String? ?? '';
    // First name only: the dashboard greets with "Welcome back, Baraqhat".
    return name.split(RegExp(r'\s+')).first;
  }

  @override
  Future<List<ExpertSession>> upcomingSessions() async {
    final rows = await _api.getList('/experts/me/sessions/?upcoming=true');
    final sessions = rows.map(_session).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return sessions;
  }

  @override
  Future<ExpertEarnings> earnings() async {
    final body = await _api.get('/experts/me/earnings/');
    final rows = await _api.getList('/experts/me/payouts/');
    return ExpertEarnings(
      available: body['available'] as int? ?? 0,
      thisWeek: body['this_week'] as int? ?? 0,
      thisWeekSessions: body['this_week_sessions'] as int? ?? 0,
      totalEarned: body['total_earned'] as int? ?? 0,
      totalSessions: body['total_sessions'] as int? ?? 0,
      nextPayout:
          DateTime.tryParse('${body['next_payout']}') ?? DateTime.now(),
      payoutMethod: body['payout_method'] as String? ?? 'Not set',
      payouts: rows.map(_payout).toList(),
    );
  }

  @override
  Future<List<BankDestination>> payoutDestinations() async {
    final rows = await _api.getList('/experts/me/payout-methods/');
    return rows.map(_destination).toList();
  }

  @override
  Future<BankDestination> addPayoutDestination({
    required String bankName,
    required String bankCode,
    required String accountNumber,
  }) async {
    final body = await _api.post('/experts/me/payout-methods/', body: {
      'kind': 'bank',
      'bank_name': bankName,
      'bank_code': bankCode,
      'account_number': accountNumber,
      'is_default': true,
    });
    return _destination(body);
  }

  @override
  Future<List<BankOption>> banks() async {
    final rows = await _api.getList('/experts/me/banks/');
    return rows.map(BankOption.fromJson).toList();
  }

  @override
  Future<void> requestPayout(int naira) async {
    await _api.post('/experts/me/payouts/', body: {'amount_naira': naira});
  }

  @override
  Future<List<AvailabilitySlot>> availability() async {
    final rows = await _api.getList('/experts/me/availability/');
    return rows.map(_slot).toList();
  }

  @override
  Future<AvailabilitySlot> addAvailability({
    required DateTime day,
    required int from,
    required int to,
  }) async {
    final body = await _api.post('/experts/me/availability/', body: {
      'day': _day(day),
      'start_minute': from,
      'end_minute': to,
    });
    return _slot(body);
  }

  @override
  Future<void> removeAvailability(String id) async {
    await _api.delete('/experts/me/availability/$id/');
  }

  @override
  Future<void> saveAvailability(List<AvailabilitySlot> slots) async {
    // There is no "replace the week" endpoint, and inventing one would mean
    // the server deleting hours it was not told about. So the difference is
    // worked out here: what the server has, against what the screen holds.
    final existing = await availability();
    final kept = {
      for (final slot in slots)
        if (slot.id.isNotEmpty) slot.id: slot,
    };

    for (final slot in existing) {
      final match = kept[slot.id];
      if (match == null) {
        await removeAvailability(slot.id);
        continue;
      }
      // An hour whose times moved is closed and reopened: the server has no
      // way to edit one, and a slot somebody has booked must not be
      // silently moved underneath them -- the delete fails first if so.
      if (match.from != slot.from ||
          match.to != slot.to ||
          !_sameDay(match.day, slot.day)) {
        await removeAvailability(slot.id);
        await addAvailability(day: match.day, from: match.from, to: match.to);
      }
    }

    for (final slot in slots.where((s) => s.id.isEmpty)) {
      await addAvailability(day: slot.day, from: slot.from, to: slot.to);
    }
  }

  @override
  Future<String> sessionNote(String sessionId) async {
    try {
      final body = await _api.get('/sessions/$sessionId/note/');
      return body['body'] as String? ?? '';
    } on NotFoundException {
      // No note written yet, which is not an error on a fresh session.
      return '';
    }
  }

  @override
  Future<void> saveSessionNote(String sessionId, String body) async {
    await _api.put('/sessions/$sessionId/note/', body: {'body': body});
  }

  @override
  Future<void> recommend({
    required String sessionId,
    required String itemId,
    String note = '',
  }) async {
    await _api.post('/experts/me/recommendations/', body: {
      'session': int.tryParse(sessionId),
      'item': int.tryParse(itemId),
      if (note.trim().isNotEmpty) 'note': note.trim(),
    });
  }

  // ------------------------------------------------------------- reading

  ExpertSession _session(Map<String, dynamic> json) => ExpertSession(
        id: '${json['id']}',
        clientName: json['client_name'] as String? ?? 'Client',
        service: _service(json['discipline'] as String? ?? ''),
        startsAt: DateTime.tryParse('${json['starts_at']}')?.toLocal() ??
            DateTime.now(),
        endsAt: DateTime.tryParse('${json['ends_at']}')?.toLocal() ??
            DateTime.now(),
        avatarAsset: ImageConstant.imgAvatarFemale,
      );

  /// The server's key, in the words the card prints.
  String _service(String discipline) => switch (discipline) {
        'therapy' => '1-on-1 Therapy',
        'yoga' => 'Yoga',
        'pilates' => 'Pilates',
        _ => discipline.isEmpty ? 'Session' : discipline,
      };

  Payout _payout(Map<String, dynamic> json) => Payout(
        id: '${json['id']}',
        label: json['label'] as String? ?? 'Payout',
        amount: json['amount_naira'] as int? ?? 0,
        paidOn: DateTime.tryParse('${json['paid_on']}') ??
            DateTime.tryParse('${json['created_at']}')?.toLocal() ??
            DateTime.now(),
      );

  BankDestination _destination(Map<String, dynamic> json) => BankDestination(
        bank: json['bank_name'] as String? ?? '',
        // Only the last four are kept -- the number itself went to the
        // provider and was never stored. `masked` reads this either way.
        accountNumber: json['last4'] as String? ?? '',
        accountName: json['account_name'] as String? ?? '',
      );

  AvailabilitySlot _slot(Map<String, dynamic> json) => AvailabilitySlot(
        id: '${json['id']}',
        day: DateTime.tryParse('${json['day']}') ?? DateTime.now(),
        from: json['start_minute'] as int? ?? 0,
        to: json['end_minute'] as int? ?? 0,
      );

  String _day(DateTime when) {
    final local = when.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
