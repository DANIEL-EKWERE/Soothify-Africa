import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/expert_recommendation.dart';
import '../../../../data/models/journal_entry.dart';
import '../../../../data/repositories/journal_repository.dart';

/// Which half of the Journal's two-way tab is showing.
enum JournalTab {
  own('Journal', 131),
  expert('Expert Recommendation', 190);

  const JournalTab(this.label, this.restingWidth);

  final String label;

  /// How wide this half is when it is *not* chosen, of the control's 342.
  ///
  /// The two are not equal — each is sized to its own label, and splitting
  /// the control down the middle ellipsises "Expert Recommendation". The
  /// chosen half then takes [selectionBonus] from the other: `259:36965`
  /// draws Journal chosen at 152 against 190, and `259:60761` draws Expert
  /// chosen at 211 against 131. Both pairs sum to 342.
  final int restingWidth;

  /// What the chosen half gains, and the other loses.
  static const int selectionBonus = 21;

  int widthWhen({required bool selected}) =>
      restingWidth + (selected ? selectionBonus : 0);
}

/// Backs the Personal Journal — Figma `259:36946` (empty) and `259:36965`
/// (populated), with the second tab at `259:60842`.
class JournalController extends BaseController {
  JournalController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final JournalRepository _repository;
  final DateTime Function() _now;

  final Rx<JournalTab> tab = JournalTab.own.obs;

  final RxList<JournalEntry> entries = <JournalEntry>[].obs;

  /// What experts have left after a session. Nothing writes these yet, so
  /// these are the frame's own rows — see [ExpertRecommendation.sample].
  late final RxList<ExpertRecommendation> recommendations =
      ExpertRecommendation.sample(now: _now).obs;

  /// The frame splits the list in two and says nothing about where the line
  /// falls. Unread is the split: it is also what the tab's own badge counts.
  List<ExpertRecommendation> get recent =>
      recommendations.where((r) => r.isNew).toList();

  List<ExpertRecommendation> get earlier =>
      recommendations.where((r) => !r.isNew).toList();

  /// The red count sitting on the tab's right end.
  int get unread => recent.length;

  bool get isEmpty => entries.isEmpty;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        entries.assignAll(await _repository.entries());
      });

  void select(JournalTab value) => tab.value = value;

  /// Writing a new note. The list reloads on the way back, so an entry saved
  /// in the composer shows without the screen being reopened.
  Future<void> compose() async {
    await Get.toNamed(AppRoutes.journalCompose);
    await load();
  }

  /// The chevron on a card. The composer is the only surface the design draws
  /// for an entry, so it doubles as the reader.
  Future<void> open(JournalEntry entry) async {
    await Get.toNamed(AppRoutes.journalCompose, arguments: entry);
    await load();
  }

  /// Opens one recommendation in full (`259:60842`), and marks it read —
  /// which is what clears both the card's "New" pill and the tab's count.
  Future<void> openRecommendation(ExpertRecommendation item) async {
    await Get.toNamed(AppRoutes.journalRecommendation, arguments: item);
    final i = recommendations.indexWhere((r) => r.id == item.id);
    if (i < 0 || !recommendations[i].isNew) return;
    recommendations[i] = ExpertRecommendation(
      id: item.id,
      expertName: item.expertName,
      sessionLabel: item.sessionLabel,
      recordedAt: item.recordedAt,
      note: item.note,
      content: item.content,
      avatarAsset: item.avatarAsset,
    );
  }
}
