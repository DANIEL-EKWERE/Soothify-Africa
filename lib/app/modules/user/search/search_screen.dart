import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/skeleton.dart';
import 'controller/search_controller.dart';

/// Searching the library.
///
/// No frame was drawn for this — the design puts the search field on four
/// screens and nothing behind it — so the results follow the shelf grid
/// (`135:20135`): the same two columns, the same cards, so a result looks
/// like what it is.
class LibrarySearchScreen extends GetView<LibrarySearchController> {
  const LibrarySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 18.h,
                      width: 18.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: Container(
                      height: 48.v,
                      padding: EdgeInsets.symmetric(horizontal: 15.h),
                      decoration: BoxDecoration(
                        color: appTheme.surface,
                        borderRadius: BorderRadius.circular(24.h),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.field,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => controller.run(),
                              style: CustomTextStyles.searchInput,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: "Let's find your calm",
                                hintStyle: CustomTextStyles.searchHint,
                              ),
                            ),
                          ),
                          Obx(
                            () => controller.query.value.isEmpty
                                ? const SizedBox.shrink()
                                : InkWell(
                                    onTap: controller.clear,
                                    child: Icon(
                                      Icons.close,
                                      size: 18.h,
                                      color: appTheme.hintText,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.results.isEmpty) {
                  return SkeletonShimmer(child: _grid(loading: true));
                }
                if (controller.results.isEmpty) {
                  return _nothing();
                }
                return _grid(loading: false);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid({required bool loading}) => GridView.builder(
        padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 32.v),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.h,
          mainAxisSpacing: 24.v,
          childAspectRatio: 163 / 174,
        ),
        itemCount: loading ? 4 : controller.results.length,
        itemBuilder: (context, i) => loading
            ? const Skeleton(width: 163, height: 174)
            : _ResultCard(item: controller.results[i]),
      );

  /// Two different empty states, because they mean different things: one is
  /// "ask me something", the other is "I looked and there is nothing".
  Widget _nothing() => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.h),
          child: Text(
            controller.searched.value
                ? 'Nothing matched “${controller.query.value.trim()}”.\n'
                    'Try a shorter word, or the name of a practitioner.'
                : 'Search the library by title, practitioner or how you '
                    'want to feel.',
            textAlign: TextAlign.center,
            style: CustomTextStyles.searchHint,
          ),
        ),
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibrarySearchController>();
    return InkWell(
      onTap: () => controller.open(item),
      borderRadius: BorderRadius.circular(8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.h),
              child: CustomImageView(
                imagePath: item.cover,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8.v),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.gridTitle,
          ),
          if (item.practitionerName.isNotEmpty)
            Text(
              item.practitionerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.gridAuthor,
            ),
        ],
      ),
    );
  }
}
