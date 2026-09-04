import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../../../../data/models/profile_stats.dart';
import '../../../../data/repositories/profile_repository.dart';

/// Backs the Profile tab — Figma "Profile/dashboard" (135:8098).
class ProfileTabController extends BaseController {
  ProfileTabController(this._repository);

  final ProfileRepository _repository;

  final Rx<ProfileSection> section = ProfileSection.dashboard.obs;
  final Rx<ProfileStats> stats = ProfileStats.empty.obs;

  List<ProfileSection> get sections => ProfileSection.values;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        stats.value = await _repository.getStats();
      });

  /// History and Check-Ins each have their own frames in the design; neither
  /// is built, so selecting them says so rather than showing an empty
  /// Dashboard under a changed pill.
  void select(ProfileSection value) {
    if (value == section.value) return;
    if (value != ProfileSection.dashboard) {
      AppFeedback.info('${value.label} is not built yet.');
      return;
    }
    section.value = value;
  }

  void openSessionNote() =>
      AppFeedback.info('Session notes are not built yet.');
}
