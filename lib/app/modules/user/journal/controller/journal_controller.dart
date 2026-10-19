import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/expert_recommendation.dart';
import '../../../../data/models/journal_entry.dart';
import '../../../../data/repositories/journal_repository.dart';
import '../../../../data/repositories/recommendation_repository.dart';
import '../../../../data/services/session_service.dart';

/// Which half of the Journal's two-way tab is showing.
enum JournalTab {
  own('Journal', 89),
  expert('Expert Recommendation', 232);

  const JournalTab(this.label, this.restingWidth);

  final String label;

  /// How wide this half is when it is *not* chosen, of the control's 342.
  ///
  /// The two are not equal — each is sized to its own label, and splitting
  /// the control down the middle ellipsises "Expert Recommendation". The
  /// chosen half then takes [selectionBonus] from the other; both pairs sum
  /// to 342.
  ///
  /// The resting pair sums to 321, not 342 — the chosen half's
  /// [selectionBonus] makes up the difference, so whichever is chosen the two
  /// fill the control exactly.
  ///
  /// The frame draws 131/190, with the unread badge hanging off the control's
  /// right end. The badge now sits inside the pill beside the label it
  /// counts, so the Expert half has to hold both: 89/232, which still leaves
  /// "Journal" more than it needs and gives "Expert Recommendation" enough to
  /// print whole in either state.
  final int restingWidth;

  /// What the chosen half gains, and the other loses.
  static const int selectionBonus = 21;

  int widthWhen({required bool selected}) =>
      restingWidth + (selected ? selectionBonus : 0);
}

/// Backs the Personal Journal — Figma `259:36946` (empty) and `259:36965`
/// (populated), with the second tab at `259:60842`.
class JournalController extends BaseController {
  JournalController(
    this._repository, {
    RecommendationRepository? recommendations,
    DateTime Function()? now,
  })  : _recommendations = recommendations,
        _now = now ?? DateTime.now;

  /// Where what experts have left comes from.
  ///
  /// Optional: without one the tab falls back to the frame's own rows,
  /// which is what the screen's goldens are drawn against and what the
  /// no-backend build shows.
  final RecommendationRepository? _recommendations;

  final JournalRepository _repository;
  final DateTime Function() _now;

  final Rx<JournalTab> tab = JournalTab.own.obs;

  final RxList<JournalEntry> entries = <JournalEntry>[].obs;

  /// What experts have left after a session.
  ///
  /// Seeded with the frame's own rows so the tab is never blank while the
  /// request is in flight, then replaced by what the server has. See
  /// [ExpertRecommendation.sample].
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
        await _loadRecommendations();
      });

  /// What experts have left, when there is a server to ask.
  ///
  /// Failures are swallowed rather than guarded: the journal half of this
  /// screen is the client's own writing and is already on the page, and
  /// taking it down over the other tab would be the wrong trade. A guest
  /// has no account for anything to have been left on, so nothing is asked.
  Future<void> _loadRecommendations() async {
    final store = _recommendations;
    if (store == null) return;
    if (Get.isRegistered<SessionService>() &&
        !Get.find<SessionService>().hasAccount) {
      recommendations.clear();
      return;
    }
    try {
      recommendations.assignAll(await store.mine());
    } catch (error) {
      Log.e('could not read what experts recommended', error: error);
    }
  }

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

    // Cleared here first so the pill goes the moment they come back, then
    // told to the server. Read on one device is read on all of them, but
    // nobody should watch a spinner to find that out.
    recommendations[i] = recommendations[i].markedRead();
    final store = _recommendations;
    if (store == null) return;
    try {
      await store.markRead(item.id);
    } catch (_) {
      // Unread again on the next load, which is the right way round to be
      // wrong: it is shown twice rather than lost.
    }
  }
}
