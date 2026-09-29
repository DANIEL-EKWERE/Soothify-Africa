import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/wellness_space.dart';
import 'controller/spaces_controller.dart';
import 'widgets/space_card.dart';

/// "Spaces Around Me" — Figma `282:25161` (list), `282:25250` (map) and
/// `282:25287` (a pin open), under the "Client Safety & Trust Screens"
/// banner `282:25385`.
///
/// One screen, two views: the frames share their header, search field and
/// filter row, and differ only below the List/Map pills at (243, 218).
///
/// Measured: the title at 70; a 298x48 search field at (24, 112) with a 24
/// radius under a `#999999` hairline; the chips at 168, 34 tall at a 16
/// radius, the selected one filled `#2F6FED`; then the list from 262 at a 282
/// pitch, or the map inset 2 and 534 tall.
class SpacesScreen extends GetView<SpacesController> {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 23.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 24.h,
                      width: 24.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text('Spaces Around Me',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.appBarTitle),
                  ),
                  SizedBox(width: 24.h),
                ],
              ),
            ),
            SizedBox(height: 20.v),
            const _SearchField(),
            SizedBox(height: 9.v),
            const _Filters(),
            SizedBox(height: 16.v),
            Expanded(
              child: Obx(
                () => controller.view.value == SpacesView.list
                    ? const _List()
                    : const _Map(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpacesController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Container(
        height: 48.v,
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(24.h),
          border: Border.all(color: appTheme.filterRule),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 20.h, color: appTheme.hintText),
            SizedBox(width: 11.h),
            Expanded(
              child: TextField(
                controller: controller.search,
                style: CustomTextStyles.spaceSearch,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Find a quiet space near you...',
                  hintStyle: CustomTextStyles.spaceSearchHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The category chips, then the List/Map pair on their own line.
///
/// The frame runs the chips off the right edge — "Wellness Spas" starts at
/// 324 on a 390 frame — so they scroll rather than wrap.
class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpacesController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 34.v,
          child: Obx(
            () => ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              children: [
                for (final category in SpaceCategory.values) ...[
                  _Chip(
                    label: category.label,
                    selected: controller.category.value == category,
                    onTap: () => controller.choose(category),
                  ),
                  if (category != SpaceCategory.values.last)
                    SizedBox(width: 8.h),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 16.v),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => Container(
                height: 28.v,
                padding: EdgeInsets.all(2.h),
                decoration: BoxDecoration(
                  color: appTheme.spaceTag,
                  borderRadius: BorderRadius.circular(16.h),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewPill(
                      label: 'List',
                      selected: controller.view.value == SpacesView.list,
                      onTap: controller.showList,
                    ),
                    _ViewPill(
                      label: 'Map',
                      selected: controller.view.value == SpacesView.map,
                      onTap: controller.showMap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.h),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 13.h),
        decoration: BoxDecoration(
          color: selected ? appTheme.soothifyBlue : appTheme.surface,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: selected ? appTheme.soothifyBlue : appTheme.textBlack,
          ),
        ),
        child: Text(
          label,
          style: selected
              ? CustomTextStyles.spaceChipSelected
              : CustomTextStyles.spaceChip,
        ),
      ),
    );
  }
}

class _ViewPill extends StatelessWidget {
  const _ViewPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.h),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 22.h),
        decoration: BoxDecoration(
          color: selected ? appTheme.onPrimary : appTheme.transparent,
          borderRadius: BorderRadius.circular(16.h),
        ),
        child: Text(
          label,
          style: selected
              ? CustomTextStyles.spaceViewSelected
              : CustomTextStyles.spaceView,
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpacesController>();
    return Obx(() {
      final spaces = controller.spaces;
      if (spaces.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.h),
            child: Text(
              'No spaces match that yet. Try another filter, or widen your '
              'search.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.spaceArea,
            ),
          ),
        );
      }
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 24.v),
        itemCount: spaces.length,
        separatorBuilder: (_, _) => SizedBox(height: 16.v),
        itemBuilder: (context, i) => SpaceCard(
          space: spaces[i],
          onTap: () => Get.toNamed(
            AppRoutes.studioProfile,
            arguments: spaces[i],
          ),
        ),
      );
    });
  }
}

/// The map view.
///
/// **A flat image, not a map view.** `282:25250` ships a 339x534 screenshot
/// with pins drawn on top, and nothing in the file says which provider the
/// real thing uses — so this places each studio's pin by the fraction stored
/// on it rather than by projecting a coordinate. Swapping in a real map means
/// replacing this widget, not the screen.
class _Map extends StatelessWidget {
  const _Map();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpacesController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(26.h, 0, 25.h, 24.v),
      child: Obx(
        () => Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.h),
                child: CustomImageView(
                  imagePath: ImageConstant.imgSpacesMap,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // One LayoutBuilder for all the pins, inside a Positioned.fill:
            // a Positioned has to be an immediate child of the Stack, so a
            // pin that measures itself cannot also position itself.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    for (final space in controller.spaces)
                      Positioned(
                        left: constraints.maxWidth * space.pin.x,
                        top: constraints.maxHeight * space.pin.y,
                        child: _Pin(
                          open: controller.selected.value == space,
                          onTap: () => controller.selectPin(space),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (controller.selected.value != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: _PinCard(space: controller.selected.value!),
              ),
            if (controller.selected.value == null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.v),
                  child: Text('Tap a pin to preview a space',
                      style: CustomTextStyles.spaceMapHint),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 19.h,
        width: 19.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.pinMarker,
          shape: BoxShape.circle,
          border: Border.all(color: appTheme.onPrimary, width: 2),
        ),
        // The open pin is the same marker the frame draws; the card at the
        // foot is what says which one is selected.
        child: open
            ? Icon(Icons.circle, size: 5.h, color: appTheme.onPrimary)
            : null,
      ),
    );
  }
}

/// The card `282:25287` raises when a pin is tapped — 339x123 at an 8 radius
/// with a 90-square photograph inset 16.
class _PinCard extends StatelessWidget {
  const _PinCard({required this.space});

  final WellnessSpace space;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.h),
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
              imagePath: space.photo,
              height: 90.h,
              width: 90.h,
              fit: BoxFit.cover,
              radius: BorderRadius.circular(4.h),
            ),
            SizedBox(width: 16.h),
            Expanded(
              child: Column(
                // Without this the Column takes every pixel the map offers
                // and the card fills the whole view.
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(space.name, style: CustomTextStyles.spaceName),
                  SizedBox(height: 4.v),
                  // The frame runs these together with no separator.
                  Text('${space.distanceLabel} ${space.area}',
                      style: CustomTextStyles.spaceArea),
                  SizedBox(height: 4.v),
                  Wrap(
                    spacing: 8.h,
                    runSpacing: 4.v,
                    children: [for (final t in space.tags) SpaceTag(t)],
                  ),
                  SizedBox(height: 8.v),
                  SpaceDirections(
                    onTap: () => Get.toNamed(
                      AppRoutes.studioProfile,
                      arguments: space,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
