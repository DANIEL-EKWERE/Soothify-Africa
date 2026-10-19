import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/expert_recommendation.dart';
import '../../../../data/models/expert_session.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';
import '../../../../data/repositories/expert_repository.dart';

/// What the practitioner is choosing from, and what they send.
///
/// Reached from the call screen: "..." offers "Recommend Contents", that
/// opens the three kinds, and choosing one opens this on that kind. The
/// kind is therefore a decision already made by the time this is built,
/// not a filter to set here.
class RecommendController extends BaseController {
  RecommendController(this._content, this._experts, {
    required this.session,
    required this.kind,
    this.pickOnly = false,
  });

  final ContentRepository _content;
  final ExpertRepository _experts;

  /// The call this came out of. The server reads the client off it.
  final ExpertSession session;

  final ExpertContentKind kind;

  /// Hand the choice back rather than sending it. See RecommendArguments.
  final bool pickOnly;

  final RxList<MediaItem> items = <MediaItem>[].obs;
  final RxString query = ''.obs;
  final Rxn<MediaItem> chosen = Rxn<MediaItem>();
  final RxBool sending = false.obs;

  final note = TextEditingController();

  String get actionLabel =>
      pickOnly ? 'Use this' : 'Send to $clientName';

  String get title => switch (kind) {
        ExpertContentKind.video => 'Recommend a video',
        ExpertContentKind.article => 'Recommend an article',
        ExpertContentKind.audio => 'Recommend audio',
      };

  String get clientName => session.clientName;

  bool get canSend => chosen.value != null && !sending.value;

  MediaType get _type => switch (kind) {
        ExpertContentKind.video => MediaType.video,
        ExpertContentKind.article => MediaType.article,
        ExpertContentKind.audio => MediaType.audio,
      };

  @override
  void onInit() {
    super.onInit();
    load();
    // GetX's own worker rather than a Timer, so it is torn down with the
    // controller and cannot fire into a disposed screen.
    debounce(query, (_) => load(), time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    note.dispose();
    super.onClose();
  }

  Future<void> load() => guard(() async {
        items.assignAll(await _content.byKind(_type, query: query.value));
        // A piece that fell out of the filtered list cannot stay chosen.
        final pick = chosen.value;
        if (pick != null && !items.any((i) => i.id == pick.id)) {
          chosen.value = null;
        }
      });

  void choose(MediaItem item) =>
      chosen.value = chosen.value?.id == item.id ? null : item;

  /// Sends it, and leaves.
  ///
  /// The call is still running behind this screen, so success returns to it
  /// rather than anywhere else -- the practitioner recommended something
  /// mid-session and is still in that session.
  ///
  /// In [pickOnly] it sends nothing: the choice goes back to whoever opened
  /// this, and they send it when they are ready.
  Future<void> send() async {
    final item = chosen.value;
    if (item == null || sending.value) return;

    if (pickOnly) {
      Get.back(result: item);
      return;
    }

    sending.value = true;
    final sent = await guard(() async {
      await _experts.recommend(
        sessionId: session.id,
        itemId: item.id,
        note: note.text,
      );
      return true;
    });
    sending.value = false;
    if (sent != true) return;

    Get.back();
    AppFeedback.success('Sent to $clientName.');
  }
}
