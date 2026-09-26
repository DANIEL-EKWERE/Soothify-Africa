import 'package:get/get.dart';

import '../../../../data/models/article.dart';
import '../controller/article_controller.dart';

/// Takes the article from the route arguments, so one route serves both.
class ArticleBinding extends Bindings {
  @override
  void dependencies() {
    final article =
        Get.arguments is Article ? Get.arguments as Article : Article.core;
    Get.lazyPut(() => ArticleController(article));
  }
}
