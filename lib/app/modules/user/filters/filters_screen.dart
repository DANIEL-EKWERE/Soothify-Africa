import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../data/models/media_filter.dart';
import 'controller/filters_controller.dart';
import 'widgets/filter_chip_grid.dart';

/// The filter sheets — Figma "Meditation/filter" (135:12427), "More Filter
/// Screen" (135:12573) and "meditation/Style filter screen" (135:12833).
/// Balance's copies (135:19379, 135:19491, 135:20011) are identical, so these
/// serve both libraries. Approach is the fourth entry in the glyph's menu and
/// the one the file never draws.
///
/// Same chrome on all of them: a back arrow and a centred heading, a
/// scrolling body, and Apply held at the bottom. The frames put Apply at the
/// end of the content, which on Duration lands it two thirds down an
/// otherwise empty screen; pinning it is the same position on the short sheet
/// and the right one on the long ones.
///
/// Nothing here links to another sheet. The frames draw each one standing
/// alone, and the menu behind the filter glyph — `showFilterMenu` — is what
/// chooses between them.
class FiltersScreen extends GetView<FiltersController> {
  const FiltersScreen({super.key, required this.kind});

  final FilterKind kind;

  String get _title => switch (kind) {
    FilterKind.duration => 'Duration',
    FilterKind.more => 'More Filters',
    FilterKind.style => 'Style',
    FilterKind.approach => 'Approach',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // The frames put the header at y=65, which is 18 below a 47pt
            // status bar — the same inset the rest of the app's pushed
            // screens use.
            SizedBox(height: 18.v),
            _Header(title: _title),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.h, 45.v, 24.h, 24.v),
                child: switch (kind) {
                  FilterKind.duration => const _DurationBody(),
                  FilterKind.more => const _MoreBody(),
                  FilterKind.style => const _StyleBody(),
                  FilterKind.approach => const _ApproachBody(),
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 24.v),
              child: Obx(
                () => CustomElevatedButton(
                  text: 'Apply',
                  isEnabled: controller.canApply,
                  onPressed: controller.apply,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FiltersController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            child: CustomImageView(
              imagePath: ImageConstant.icChevronLeft,
              height: 24.h,
              width: 24.h,
              color: appTheme.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: CustomTextStyles.filterHeading,
            ),
          ),
          // On every sheet, not just one: a questionnaire you can only add to
          // is a trap, and the frames put this on the sheet they drew it on
          // because that is the sheet they drew.
          Obx(
            () => InkWell(
              onTap: controller.canApply ? controller.clearAll : null,
              child: Text(
                'Clear all',
                style: controller.canApply
                    ? CustomTextStyles.filterClearAll
                    : CustomTextStyles.filterClearAll
                        .copyWith(color: appTheme.paymentHintInk),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Duration's seven chips and nothing else — the frame leaves the rest of
/// the screen blank.
class _DurationBody extends StatelessWidget {
  const _DurationBody();

  @override
  Widget build(BuildContext context) =>
      const FilterChipGrid(group: FilterGroup.duration);
}

/// The one sheet with no content in the file.
///
/// The menu lists Approach beside the other three, so the row has to lead
/// somewhere; what it leads to says so plainly rather than showing an empty
/// sheet with a dead Apply and no explanation.
class _ApproachBody extends StatelessWidget {
  const _ApproachBody();

  @override
  Widget build(BuildContext context) {
    if (FilterGroup.approach.options.isNotEmpty) {
      return const FilterChipGrid(group: FilterGroup.approach);
    }
    return Padding(
      padding: EdgeInsets.only(top: 80.v),
      child: Text(
        'Approach filters are on the way.',
        textAlign: TextAlign.center,
        style: CustomTextStyles.filterGroupLabel,
      ),
    );
  }
}

/// The 2px rule the More Filters frame sets between groups.
class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) =>
      Container(height: 2.v, color: appTheme.filterRule);
}

class _MoreBody extends StatelessWidget {
  const _MoreBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, group) in FilterGroup.more.indexed) ...[
          if (i > 0) ...[
            SizedBox(height: 40.v),
            const _Rule(),
            SizedBox(height: 40.v),
          ],
          Text(group.label, style: CustomTextStyles.filterGroupLabel),
          SizedBox(height: 8.v),
          FilterChipGrid(group: group),
        ],
      ],
    );
  }
}

/// Style's seven cards — 140x122 in two columns, 24 apart both ways.
class _StyleBody extends StatelessWidget {
  const _StyleBody();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FiltersController>();
    return Padding(
      // The cards sit at x=43 in a 390 frame, inset a further 19 from the
      // 24 the rest of the sheet uses.
      padding: EdgeInsets.symmetric(horizontal: 19.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 24.h,
          mainAxisSpacing: 24.v,
          childAspectRatio: 140 / 122,
        ),
        itemCount: FilterStyle.all.length,
        itemBuilder: (context, i) {
          final style = FilterStyle.all[i];
          return Obx(
            () => _StyleCard(
              style: style,
              selected: controller.isSelected(FilterGroup.style, style.title),
              onTap: () => controller.toggle(FilterGroup.style, style.title),
            ),
          );
        },
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final FilterStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 13.h, vertical: 10.v),
        decoration: BoxDecoration(
          // As with a chip: the blue outline is the whole of the selected
          // state, per `259:30732`.
          color: appTheme.filterChipFill,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(
            color: selected
                ? appTheme.soothifyBlue
                : appTheme.filterChipBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              style.title,
              textAlign: TextAlign.center,
              style: CustomTextStyles.filterStyleTitle,
            ),
            SizedBox(height: 4.v),
            Flexible(
              child: Text(
                style.description,
                textAlign: TextAlign.center,
                style: CustomTextStyles.filterStyleBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
