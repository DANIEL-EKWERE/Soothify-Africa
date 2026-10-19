import 'package:get/get.dart';

import '../../../../data/models/expert_recommendation.dart';
import '../../../../data/models/expert_session.dart';
import '../../../../data/repositories/content_repository.dart';
import '../../../../data/repositories/expert_repository.dart';
import '../controller/recommend_controller.dart';

/// The picker is opened with `(session, kind)` — see RecommendArguments.
class RecommendBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    Get.lazyPut(() => RecommendController(
          Get.find<ContentRepository>(),
          Get.find<ExpertRepository>(),
          session: args is RecommendArguments
              ? args.session
              : const ExpertSessionPlaceholder().value,
          kind: args is RecommendArguments
              ? args.kind
              : ExpertContentKind.video,
          pickOnly: args is RecommendArguments && args.pickOnly,
        ));
  }
}

/// What the call screen passes through the route.
class RecommendArguments {
  const RecommendArguments({
    required this.session,
    required this.kind,
    this.pickOnly = false,
  });

  final ExpertSession session;
  final ExpertContentKind kind;

  /// Hand the choice back instead of sending it.
  ///
  /// The call screen sends there and then -- the session is running and
  /// the client is on the other end. The notes screen is written after,
  /// and sends the recommendation when the note is saved, so it only wants
  /// the choice.
  final bool pickOnly;
}

/// Only reached if the route is opened without arguments, which the app
/// never does; a placeholder beats a crash in that case.
class ExpertSessionPlaceholder {
  const ExpertSessionPlaceholder();

  ExpertSession get value => ExpertSession(
        id: '',
        clientName: 'your client',
        service: '',
        startsAt: DateTime.now(),
        endsAt: DateTime.now(),
      );
}
