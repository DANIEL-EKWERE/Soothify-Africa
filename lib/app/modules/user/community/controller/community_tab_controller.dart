import '../../../../core/app_export.dart';
import '../../../../data/models/community_topic.dart';

/// Which step of the community onboarding the tab is showing.
///
/// All three frames carry the bottom navigation, so they are steps inside the
/// tab rather than separate routes.
enum CommunityStage { welcome, username, topics }

/// Backs the Community tab — Figma 135:5758, 135:5768 and 135:4996.
class CommunityTabController extends GetxController {
  final Rx<CommunityStage> stage = CommunityStage.welcome.obs;

  /// Multi-select: the screen asks you to "find conversations by topics that
  /// interest you", plural. The frame happens to show exactly one chip
  /// outlined, which single-select would also produce — worth confirming.
  final RxSet<String> selected = <String>{'depression'}.obs;

  final RxString username = ''.obs;

  /// What the username field currently holds, before it is committed.
  final RxString usernameDraft = ''.obs;

  List<CommunityTopic> get topics => CommunityTopic.values;

  String get location => 'Abuja';

  /// The handle, once chosen — the community is pseudonymous, so the topics
  /// header greets you by it rather than by the account name.
  String get displayName => username.value.isEmpty ? 'Friend' : username.value;

  @override
  void onInit() {
    super.onInit();
    restore();
  }

  /// Resumes where the user left off: past the welcome once seen, past the
  /// handle once chosen.
  void restore() {
    final prefs = PrefUtils();
    username.value = prefs.communityUsername() ?? '';
    usernameDraft.value = username.value;
    if (username.value.isNotEmpty) {
      stage.value = CommunityStage.topics;
    } else if (prefs.communityWelcomeSeen()) {
      stage.value = CommunityStage.username;
    } else {
      stage.value = CommunityStage.welcome;
    }
  }

  Future<void> dismissWelcome() async {
    await PrefUtils().setCommunityWelcomeSeen(true);
    stage.value = CommunityStage.username;
  }

  bool get canCreateUsername => usernameDraft.value.trim().length >= 3;

  Future<void> createUsername() async {
    final value = usernameDraft.value.trim();
    if (value.length < 3) return;
    username.value = value;
    await PrefUtils().setCommunityUsername(value);
    stage.value = CommunityStage.topics;
  }

  bool isSelected(CommunityTopic topic) => selected.contains(topic.id);

  bool get canProceed => selected.isNotEmpty;

  void toggle(CommunityTopic topic) {
    if (!selected.remove(topic.id)) selected.add(topic.id);
  }

  void proceed() {
    if (!canProceed) return;
    Get.toNamed(AppRoutes.communityForum);
  }
}
