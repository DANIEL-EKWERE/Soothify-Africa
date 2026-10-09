import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/filter_glyph.dart';
import '../../../data/models/media_item.dart';
import 'controller/discovery_tab_controller.dart';
import 'widgets/discovery_card.dart';
import 'widgets/subscription_card.dart';

/// Discovery — Figma "Discovery" (135:3363).
///
/// A search field, two horizontal shelves, and the subscription card. The
/// frame carries its own bottom navigation at y=1071; that is skipped here
/// because the shell supplies it.
///
/// Tapping the field swaps the whole tab for [_SearchView]; everything else
/// here is [_BrowseView].
class DiscoveryTab extends GetView<DiscoveryTabController> {
  const DiscoveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Obx(
          () => controller.searching.value
              ? const _SearchView()
              : const _BrowseView(),
        ),
      ),
    );
  }
}

/// Discovery as it opens: search, the Spaces card, two shelves, the plans.
class _BrowseView extends GetView<DiscoveryTabController> {
  const _BrowseView();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(24.h, 31.v, 24.h, 32.v),
        children: [
          Text(
            'Discovery',
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
          SizedBox(height: 24.v),
          const _SearchRow(),
          SizedBox(height: 16.v),
          const _SpacesButton(),
          SizedBox(height: 21.v),
          Obx(
            () => _Shelf(
              title: 'Recent',
              items: controller.recent.toList(),
              onTap: controller.open,
            ),
          ),
          SizedBox(height: 40.v),
          Obx(
            () => _Shelf(
              title: 'Popular',
              items: controller.popular.toList(),
              onTap: controller.open,
            ),
          ),
          SizedBox(height: 40.v),
          Obx(
            () => SubscriptionCard(
              plans: controller.plans.toList(),
              selectedPlanId: controller.selectedPlanId.value,
              freeTrial: controller.freeTrial.value,
              onPlanSelected: controller.selectPlan,
              onFreeTrialChanged: controller.toggleFreeTrial,
              ctaLabel: controller.ctaLabel,
              onSubscribe: controller.subscribe,
            ),
          ),
        ],
      ),
    );
  }
}

/// Discovery with the field live: a back arrow, the focused field, and
/// whichever of the three states the search is in.
///
/// Only the "searching" state came from the designer, so the spinner row is
/// measured and the other two reuse Discovery's own card and type.
class _SearchView extends GetView<DiscoveryTabController> {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // System back leaves the search rather than the tab, which is where
      // the arrow in the header goes too.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.closeSearch();
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.h, 31.v, 24.h, 0),
            child: Column(
              children: [
                Text(
                  'Discovery',
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.appBarTitle,
                ),
                SizedBox(height: 24.v),
                const _SearchRow(active: true),
              ],
            ),
          ),
          Expanded(child: Obx(() => _searchBody())),
        ],
      ),
    );
  }

  Widget _searchBody() {
    if (controller.searchBusy.value) {
      return Padding(
        padding: EdgeInsets.only(top: 22.v),
        child: Align(
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 22.h,
                width: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 3.h,
                  color: appTheme.soothifyBlue,
                  backgroundColor: appTheme.soothifyBlue.withValues(alpha: 0.2),
                ),
              ),
              SizedBox(width: 12.h),
              Flexible(
                child: Text(
                  'Searching for \u201C${controller.query.value.trim().toLowerCase()}\u201D...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.searchStatus,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final results = controller.results.toList();
    if (results.isEmpty) {
      if (!controller.searched.value) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.fromLTRB(24.h, 48.v, 24.h, 0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 40.h, color: appTheme.navInactive),
            SizedBox(height: 16.v),
            Text('No results found', style: CustomTextStyles.searchStatus),
            SizedBox(height: 8.v),
            Text(
              'Nothing matches \u201C${controller.query.value.trim()}\u201D yet. '
              'Try a different word.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.searchEmptyBody,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 32.v),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.h,
        mainAxisSpacing: 20.v,
        childAspectRatio: 159 / 166,
      ),
      itemCount: results.length,
      // 161 is the cell the delegate hands back on the design frame
      // ((390 - 48 gutters - 20 gap) / 2); the card sizes itself, so it has
      // to be told the same number.
      itemBuilder: (context, i) => DiscoveryCard(
        item: results[i],
        width: 161,
        onTap: () => controller.open(results[i], source: 'Search'),
      ),
    );
  }
}

/// The way into "Spaces Around Me" (`282:25161`).
///
/// The design gives that screen no entry point of its own, so this placement
/// is a decision, not the file's: directly under Discover's search field,
/// because both answer "what is out there for me", and one is the physical
/// version of the other. The card itself is the designer's, measured off the
/// screenshot they supplied.
class _SpacesButton extends StatelessWidget {
  const _SpacesButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.spaces),
      borderRadius: BorderRadius.circular(16.h),
      // Clip.none so the tag can sit over the card's top edge, which is
      // where the screenshot puts it — 4.5 above it and 3 in from the right.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 96.v,
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            decoration: BoxDecoration(
              gradient: appTheme.spacesEntryGradient,
              borderRadius: BorderRadius.circular(16.h),
            ),
            child: Row(
              children: [
                Container(
                  height: 56.v,
                  width: 56.h,
                  decoration: BoxDecoration(
                    // White at 10% rather than the flat #4051E7 it composites to,
                    // so the tile keeps its lift wherever it sits on the gradient.
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14.h),
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 30.h,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Spaces Around Me',
                        style: CustomTextStyles.spacesEntryTitle,
                      ),
                      SizedBox(height: 4.v),
                      Text(
                        'Find studios & wellness spaces near you',
                        style: CustomTextStyles.spacesEntrySubtitle,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.h),
                Icon(Icons.chevron_right, size: 28.h, color: Colors.white),
              ],
            ),
          ),
          Positioned(top: -4.5.v, right: 3.h, child: const _NewTag()),
        ],
      ),
    );
  }
}

/// The "NEW" tag over the Spaces card's top-right corner.
class _NewTag extends StatelessWidget {
  const _NewTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21.5.v,
      width: 35.5.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: appTheme.authAccent,
        borderRadius: BorderRadius.circular(6.h),
      ),
      child: Text('NEW', style: CustomTextStyles.newTag),
    );
  }
}

/// The field, in both of its states.
///
/// Inactive it is a button that turns the search on. Active it is a real
/// field: a back arrow appears to its left, the filter glyph gives way to the
/// width, and the outline turns blue while it holds focus.
class _SearchRow extends StatefulWidget {
  const _SearchRow({this.active = false});

  final bool active;

  @override
  State<_SearchRow> createState() => _SearchRowState();
}

class _SearchRowState extends State<_SearchRow> {
  final DiscoveryTabController controller = Get.find<DiscoveryTabController>();
  late final TextEditingController _text = TextEditingController(
    text: controller.query.value,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _close() {
    FocusScope.of(context).unfocus();
    controller.closeSearch();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: controller.openSearch,
              borderRadius: BorderRadius.circular(24.h),
              child: _field(
                border: appTheme.searchBorder,
                child: Flexible(
                  // Flexible so a large system text scale shortens the hint
                  // rather than overflowing the field.
                  child: Text(
                    'What can we help you find?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.searchHint,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 19.h),
          Obx(
            () => FilterGlyph(
              count: controller.filters.value.count,
              onTap: controller.openFilters,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        InkWell(
          onTap: _close,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.v, horizontal: 2.h),
            child: CustomImageView(
              imagePath: ImageConstant.icBack,
              height: 18.h,
              width: 18.h,
              color: appTheme.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 14.h),
        Expanded(
          child: _field(
            border: appTheme.soothifyBlue,
            child: Expanded(
              child: TextField(
                controller: _text,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: controller.onQueryChanged,
                onSubmitted: (_) => controller.runSearch(),
                style: CustomTextStyles.searchInput,
                cursorColor: appTheme.soothifyBlue,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'What can we help you find?',
                  hintStyle: CustomTextStyles.searchHint,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The pill both states share — only the outline colour and what sits after
  /// the magnifier differ.
  Widget _field({required Color border, required Widget child}) {
    return Container(
      height: 48.v,
      padding: EdgeInsets.symmetric(horizontal: 15.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(24.h),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CustomImageView(
            imagePath: ImageConstant.icSearch,
            height: 18.h,
            width: 18.h,
            color: appTheme.textPrimary,
          ),
          SizedBox(width: 14.h),
          child,
        ],
      ),
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf({required this.title, required this.items, required this.onTap});

  final String title;
  final List<MediaItem> items;
  final ValueChanged<MediaItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.sectionTitle,
              ),
            ),
            InkWell(
              onTap: () => Get.find<DiscoveryTabController>().openShelf(title),
              child: Text('See All', style: CustomTextStyles.seeAll),
            ),
          ],
        ),
        SizedBox(height: 16.v),
        SizedBox(
          height: 166.v,
          // Scrolls past the frame edge — the design shows a third card
          // clipped at x=390, so the shelf is meant to run off-screen.
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(width: 20.h),
            itemBuilder: (context, i) =>
                DiscoveryCard(item: items[i], onTap: () => onTap(items[i])),
          ),
        ),
      ],
    );
  }
}
