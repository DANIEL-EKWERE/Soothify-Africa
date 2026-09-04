import 'package:flutter/widgets.dart';

import '../../../../../core/app_export.dart';
import '../../../../../core/base_controller.dart';
import '../../../../../data/repositories/community_repository.dart';

/// Backs "Start a discussion" — Figma 135:5783.
class ComposeController extends BaseController {
  ComposeController(this._repository);

  final CommunityRepository _repository;

  final TextEditingController body = TextEditingController();
  final RxBool canPost = false.obs;

  @override
  void onInit() {
    super.onInit();
    body.addListener(_sync);
  }

  void _sync() => canPost.value = body.text.trim().isNotEmpty;

  @override
  void onClose() {
    body
      ..removeListener(_sync)
      ..dispose();
    super.onClose();
  }

  Future<void> post() async {
    if (!canPost.value) return;
    final author = PrefUtils().communityUsername() ?? 'Anonymous';
    final result = await guard(
      () => _repository.post(body: body.text, author: author),
    );
    // Only report success when the write actually succeeded — guard returns
    // null on failure and has already surfaced the error.
    if (result != null) Get.back(result: true);
  }
}
