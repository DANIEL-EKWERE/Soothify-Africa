import 'package:flutter/widgets.dart';

import '../../../../../core/app_export.dart';
import '../../../../../core/base_controller.dart';
import '../../../../../data/models/comment.dart';
import '../../../../../data/models/discussion.dart';
import '../../../../../data/repositories/community_repository.dart';

/// Backs a discussion thread — Figma "On going discussion comments"
/// (135:6190).
class ThreadController extends BaseController {
  ThreadController(
    this._repository,
    this.discussion, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final CommunityRepository _repository;

  /// The thread's own post, shown at the head. Passed in rather than refetched
  /// — the list already has it, and refetching would blank the card on open.
  final Discussion discussion;

  final DateTime Function() _now;

  final RxList<Comment> comments = <Comment>[].obs;
  final TextEditingController message = TextEditingController();
  final RxBool canSend = false.obs;

  DateTime get now => _now();

  @override
  void onInit() {
    super.onInit();
    message.addListener(_sync);
    load();
  }

  void _sync() => canSend.value = message.text.trim().isNotEmpty;

  @override
  void onClose() {
    message
      ..removeListener(_sync)
      ..dispose();
    super.onClose();
  }

  Future<void> load() => guard(() async {
        comments.assignAll(await _repository.getComments(discussion.id));
      });

  Future<void> send() async {
    if (!canSend.value) return;
    final author = PrefUtils().communityUsername() ?? 'Anonymous';
    final created = await guard(
      () => _repository.comment(
        discussionId: discussion.id,
        body: message.text,
        author: author,
      ),
    );
    // Clear only on a real write; guard returns null on failure and has
    // already surfaced the error, so the text stays put to retry.
    if (created != null) {
      comments.add(created);
      message.clear();
    }
  }

  void reply(Comment comment) =>
      AppFeedback.info('Replying to a comment is not built yet.');
}
