import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/repositories/expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/availability/controller/slot_editor_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/dashboard/controller/expert_dashboard_controller.dart';

/// Setting hours for the first time.
///
/// The server returns only the slots a practitioner has already made, so a
/// new one saw an empty list — and the only way into the time picker was a
/// chevron inside a row, which did not exist. The picker itself could only
/// rewrite a slot it was given, so even reaching it wrote nothing.
class _NoSlots extends MockExpertRepository {
  _NoSlots({super.now});

  final List<({DateTime day, int from, int to})> added = [];

  @override
  Future<List<AvailabilitySlot>> availability() async => const [];

  @override
  Future<AvailabilitySlot> addAvailability({
    required DateTime day,
    required int from,
    required int to,
  }) async {
    added.add((day: day, from: from, to: to));
    return AvailabilitySlot(
      id: 'new-${added.length}',
      day: day,
      from: from,
      to: to,
    );
  }
}

void main() {
  DateTime now() => DateTime(2026, 10, 26, 9);

  late _NoSlots repository;
  late ExpertDashboardController dashboard;

  setUp(() async {
    Get.testMode = true;
    repository = _NoSlots(now: now);
    Get.put<ExpertRepository>(repository);
    dashboard = Get.put(ExpertDashboardController(repository, now: now));
    await dashboard.load();
  });

  tearDown(Get.reset);

  test('a practitioner who has set none starts with none', () {
    expect(dashboard.slots, isEmpty);
  });

  test('the picker opened with nothing to edit creates hours', () async {
    // It used to leave without writing anything, so the screen could only
    // ever edit what was already there.
    final editor = SlotEditorController(dashboard)
      ..setHour(14)
      ..setMinute(30);

    await editor.save();

    expect(repository.added, hasLength(1));
    expect(repository.added.single.from, 14 * 60 + 30);
    expect(dashboard.slots, hasLength(1));
  });

  test('a repeat writes one window per day chosen', () async {
    final editor = SlotEditorController(dashboard)..setHour(9);
    editor.toggleEveryday();

    await editor.save();

    // The frame's seven circles are what the practitioner chose; saving
    // one day of a seven-day repeat would discard the other six.
    expect(repository.added, hasLength(7));
    expect(dashboard.slots, hasLength(7));
  });

  test('the new hours arrive in order', () async {
    final editor = SlotEditorController(dashboard)..setHour(8);
    editor.toggleEveryday();

    await editor.save();

    final days = dashboard.slots.map((s) => s.day).toList();
    expect(days, orderedEquals([...days]..sort()));
  });

  test('an hour long by default, as the frame has it', () async {
    final editor = SlotEditorController(dashboard)..setHour(11);

    await editor.save();

    final made = repository.added.single;
    expect(made.to - made.from, 60);
  });

  test('editing an existing one still replaces it', () async {
    final editor = SlotEditorController(dashboard)..setHour(7);
    await editor.save();
    final existing = dashboard.slots.single;

    final again = SlotEditorController(dashboard, slot: existing)
      ..setHour(10);
    await again.save();

    // Closed and reopened rather than edited: an hour is a row the
    // client's calendar reads.
    expect(dashboard.slots.single.from, 10 * 60);
    expect(dashboard.slots, hasLength(1));
  });
}
