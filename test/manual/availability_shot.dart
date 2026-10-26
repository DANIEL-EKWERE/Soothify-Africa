import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/repositories/expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/availability/expert_availability_screen.dart';
import 'package:soothifyafrica/app/modules/practitioner/dashboard/controller/expert_dashboard_controller.dart';

import '../helpers.dart';

/// Update Availability, with and without hours set -- a screenshot, not a
/// check. Deliberately outside the suite: named `_test.dart` under `test/`
/// it was collected by `flutter test`, where it never finished and left the
/// whole run hanging after all 746 others had reported.
///
/// Run it on its own:
///   flutter test --update-goldens test/manual/availability_shot.dart
class _NoSlots extends MockExpertRepository {
  _NoSlots({super.now});

  @override
  Future<List<AvailabilitySlot>> availability() async => const [];
}

void main() {
  DateTime now() => DateTime(2026, 10, 26, 9);

  tearDown(Get.reset);

  Future<void> mount(WidgetTester tester, ExpertRepository repository) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ExpertRepository>(repository);
    final dashboard =
        Get.put(ExpertDashboardController(repository, now: now));
    await dashboard.load();
    await pumpScreen(tester, const ExpertAvailabilityScreen());
  }

  testWidgets('nothing set yet', (tester) async {
    await mount(tester, _NoSlots(now: now));

    await expectLater(find.byType(ExpertAvailabilityScreen),
        matchesGoldenFile('goldens/availability_empty.png'));
  });

  testWidgets('hours already set', (tester) async {
    await mount(tester, MockExpertRepository(now: now));

    await expectLater(find.byType(ExpertAvailabilityScreen),
        matchesGoldenFile('goldens/availability_filled.png'));
  });
}
