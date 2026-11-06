import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/base_controller.dart';
import '../../../data/models/studio_partner.dart';
import '../../../data/repositories/partner_repository.dart';

/// Backs the door — Figma "5.3 · Live roster & verification" (`416:26667`),
/// its error state (`416:26744`), the dispute dialog (`416:26781`) and the
/// roster once provisional entry has been granted (`416:26850`).
///
/// One controller for all four: they are one screen in four states, and the
/// roster behind them never changes.
class RosterController extends BaseController {
  RosterController(this._repository, {String? classId})
      : classId = classId ??
            (Get.arguments is String ? Get.arguments as String : '1');

  final PartnerRepository _repository;
  final String classId;

  final Rxn<StudioRoster> roster = Rxn<StudioRoster>();
  final entryCode = TextEditingController();

  /// The failed attempt now showing, or null when the desk is clear.
  final Rxn<CheckInOutcome> failure = Rxn<CheckInOutcome>();

  /// What was granted provisionally, for the banner on `416:26850`.
  final Rxn<RosterMember> granted = Rxn<RosterMember>();
  final RxList<CheckInProblem> reasons = <CheckInProblem>[].obs;

  final RxBool verifying = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() =>
      guard(() async => roster.value = await _repository.roster(classId));

  @override
  void onClose() {
    entryCode.dispose();
    super.onClose();
  }

  /// The six characters the desk types. The hyphen is automatic, as the
  /// hint under the field says, so it is stripped before anything is sent.
  String get typedCode =>
      entryCode.text.replaceAll('-', '').trim().toUpperCase();

  bool get canVerify => typedCode.length >= 6 && !verifying.value;

  /// Nudged per keystroke so [canVerify] has something to rebuild on.
  final RxInt edits = 0.obs;

  void touch() => edits.value++;

  Future<void> verify() async {
    if (!canVerify) return;
    verifying.value = true;
    final outcome = await guard(
      () => _repository.verifyEntry(classId, _withHyphen(typedCode)),
      setLoading: false,
    );
    verifying.value = false;
    if (outcome == null) return;

    if (outcome.ok) {
      await load();
      failure.value = null;
      entryCode.clear();
      Get.toNamed(AppRoutes.partnerCheckInDone, arguments: outcome.member);
      return;
    }
    // Not thrown: a code that does not work is an answer the desk acts on,
    // and the frame gives it a whole screen.
    failure.value = outcome;
  }

  /// "Try Again" — back to the keypad with the code cleared.
  void retry() {
    failure.value = null;
    entryCode.clear();
    touch();
  }

  /// The scanner. What it reads is verified exactly as a typed code is —
  /// the door should not have two ways of deciding who gets in.
  Future<void> scan() async {
    final scanned = await Get.toNamed(AppRoutes.partnerScanner);
    if (scanned is! String || scanned.trim().isEmpty) return;
    entryCode.text = scanned.trim().toUpperCase();
    touch();
    await verify();
  }

  void toggleReason(CheckInProblem problem) {
    reasons.contains(problem)
        ? reasons.remove(problem)
        : reasons.add(problem);
  }

  bool get canSubmitDispute => reasons.isNotEmpty;

  /// "Submit & Grant Entry". The member gets into class now and the studio
  /// is not left arguing at the door; the admin log sorts it out after.
  Future<void> grantEntry() async {
    final member = failure.value?.member;
    if (member == null || !canSubmitDispute) return;

    final updated = await guard(
      () => _repository.grantProvisional(
        classId,
        member.id,
        problems: [...reasons],
      ),
    );
    if (updated == null) return;

    await load();
    granted.value = updated;
    failure.value = null;
    reasons.clear();
    entryCode.clear();
    Get.back();
  }

  /// "3 admitted · 2 verified · 1 provisional".
  String get admittedSummary {
    final r = roster.value;
    if (r == null) return '';
    return '${r.admitted} admitted · ${r.verified} verified · '
        '${r.provisional} provisional';
  }

  /// "2 checked in · 1 not arrived" — the pale strip over the table.
  String get arrivalSummary {
    final r = roster.value;
    if (r == null) return '';
    return '${r.admitted} checked in · ${r.notArrived} not arrived';
  }

  static String _withHyphen(String code) =>
      code.length > 3 ? '${code.substring(0, 3)}-${code.substring(3)}' : code;
}
