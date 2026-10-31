import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/app_tab.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/profile_stats.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../shell/controller/shell_controller.dart';

/// Backs the Profile tab — Figma "Profile/dashboard" (135:8098).
class ProfileTabController extends BaseController {
  ProfileTabController(
    this._repository,
    this._session, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// Injectable, because the calendar opens on today and a golden
  /// recorded against the wall clock goes stale the next day.
  final DateTime Function() _now;

  final SessionService _session;

  /// Browsing without an account — Profile offers sign-up instead of stats.
  ///
  /// Reads the observable rather than the plain getter, so a screen that
  /// consults it inside an Obx rebuilds when the session ends. Without that
  /// an expiry left this tab drawing a signed-in user while Home — rebuilt
  /// by something else — had already dropped to the guest header.
  bool get isGuest => _session.role.value == null;

  /// "Unlock Soothify Pro" on the guest card.
  ///
  /// It used to call `toNamed(shell)` — pushing a second copy of the shell
  /// the user was already inside, which looked like nothing happening. Plans
  /// is a tab, so the way to it is the shell's own selection.
  void openPlans() {
    if (Get.isRegistered<ShellController>()) {
      Get.find<ShellController>().current.value = AppTab.plans;
      return;
    }
    Get.toNamed(AppRoutes.shell);
  }

  final ProfileRepository _repository;

  final Rx<ProfileSection> section = ProfileSection.dashboard.obs;
  final Rx<ProfileStats> stats = ProfileStats.empty.obs;

  /// "This week · 5–11 Oct" — the range the server says it counted, so the
  /// heading cannot claim a week the numbers are not for.
  String get weekLabel {
    final from = stats.value.weekStart;
    final to = stats.value.weekEnd;
    if (from == null || to == null) return 'This week';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    // "5–11 Oct" within one month; "28 Sep – 4 Oct" across two.
    final tail = from.month == to.month
        ? '${from.day}\u2013${to.day} ${months[to.month - 1]}'
        : '${from.day} ${months[from.month - 1]} \u2013 '
            '${to.day} ${months[to.month - 1]}';
    return 'This week \u00b7 $tail';
  }

  /// The line above the button, as the design writes it.
  String get cardLead => 'A little movement, a little more balance.';

  /// "5 active days · Time well spent on you".
  String get activeDaysLine {
    final days = stats.value.activeDays;
    if (days == 0) return 'Nothing yet this week \u00b7 there is still time';
    final word = days == 1 ? 'active day' : 'active days';
    return '$days $word \u00b7 Time well spent on you';
  }

  List<ProfileSection> get sections => ProfileSection.values;

  /// The month the History calendar is showing.
  ///
  /// This month, not the design's August 2024: the frame prints a date
  /// because a frame has to print something, and shipping it meant the
  /// calendar opened two years ago with nothing on it.
  late final Rx<DateTime> month =
      DateTime(_now().year, _now().month).obs;

  /// The day whose activity is listed. Today to begin with, so the screen
  /// opens on something rather than on an unanswered question.
  late final Rxn<DateTime> selectedDate = Rxn<DateTime>(_today);

  DateTime get _today {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }

  void selectDate(DateTime date) => selectedDate.value = date;

  /// What was played on the chosen day, newest first.
  List<RecentPlay> get historyForSelectedDay {
    final day = selectedDate.value;
    if (day == null) return stats.value.recent;
    return stats.value.recent.where((row) {
      final at = row.playedAt;
      return at != null && DateUtils.isSameDay(at, day);
    }).toList();
  }

  /// The days the calendar marks — the ones with something on them.
  Set<DateTime> get daysWithActivity => {
        for (final row in stats.value.recent)
          if (row.playedAt != null)
            DateTime(
              row.playedAt!.year,
              row.playedAt!.month,
              row.playedAt!.day,
            ),
      };

  /// Whether the chosen day is today, for the empty state's wording.
  bool get showingToday {
    final day = selectedDate.value;
    return day != null && DateUtils.isSameDay(day, _today);
  }

  /// Mood opens a calendar of past check-ins; the two daily habits have their
  /// own screen, with a reminder behind it.
  ///
  /// Journal opens the Journal itself. Its `Profile/journal checkin` frames
  /// turn out to be pixel-identical to the `Journal` ones — the two rows are
  /// the same screens under two names — and the check-in calendar had nothing
  /// to draw for this kind, so it was a permanently empty month. This is also
  /// the only way into the Journal: nothing else routed to it.
  void openCheckin(CheckinKind kind) => Get.toNamed(
        switch (kind) {
          CheckinKind.mood => AppRoutes.checkin,
          CheckinKind.journal => AppRoutes.journal,
          CheckinKind.meditation || CheckinKind.balance => AppRoutes.daily,
          // Straight into the minute. There is no history screen behind it
          // and no reminder to set up, so the card is the whole way in.
          CheckinKind.breathing => AppRoutes.breathe,
        },
        arguments: kind,
      );

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        // The three counters are this person's own. A guest has no account
        // for the server to count anything about, so the tab shows the
        // empty figures the design already draws rather than an error.
        if (!_session.hasAccount) {
          stats.value = ProfileStats.empty;
          return;
        }
        stats.value = await _repository.getStats();
      });

  void select(ProfileSection value) => section.value = value;

  /// The card on Profile that looks like it opens a session note.
  ///
  /// It does not, and will not: the note a practitioner writes is clinical,
  /// and the server never serves it to the client it is about. Said plainly
  /// rather than left as "not built yet", which promises it one day.
  void openSessionNote() => AppFeedback.info(
        'Your practitioner’s notes are private to them. Ask them in your '
        'next session if you would like to talk one through.',
      );
}
