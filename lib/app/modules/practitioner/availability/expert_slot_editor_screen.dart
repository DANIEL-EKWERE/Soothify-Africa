import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/month_calendar.dart';
import '../widgets/expert_header.dart';
import 'controller/slot_editor_controller.dart';

/// Editing one bookable window — Figma "Avaliability" (`259:60077`) and
/// "Avaliability calendar pop" (`259:60133`), which is the same screen with a
/// month calendar over it.
///
/// Measured: the wheel rows at 141, 209 and 277 — a 68 pitch with the middle
/// one focused — hours at x=110, the colon at 192 and minutes at 222, all
/// Nunito Sans 700 32. The repeat card is 342x109 at 349 with "Everyday" at
/// 373 and seven 23.1 circles at 411, 44.1 apart. "Save Availability" at 479.
///
/// The frame sets the letters in **Poppins**, which the app does not bundle;
/// single capitals in Nunito Sans read the same at 10pt.
class ExpertSlotEditorScreen extends GetView<SlotEditorController> {
  const ExpertSlotEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            // The frame misspells its own title as "Update Availabilty".
            const ExpertHeader(title: 'Update Availability'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 37.v, 24.h, 24.v),
                children: [
                  const _TimeWheels(),
                  SizedBox(height: 40.v),
                  const _RepeatCard(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
              child: CustomElevatedButton(
                text: 'Save Availability',
                onPressed: controller.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two wheels with a colon between them, the focused row in the middle.
class _TimeWheels extends StatelessWidget {
  const _TimeWheels();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SlotEditorController>();
    return SizedBox(
      height: 204.v,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => _Wheel(
              count: 24,
              value: controller.hour.value,
              onChanged: controller.setHour,
            ),
          ),
          SizedBox(
            width: 30.h,
            child: Text(':',
                textAlign: TextAlign.center,
                style: CustomTextStyles.slotWheelFocused),
          ),
          Obx(
            () => _Wheel(
              // Quarter hours: the design's own slots start on the hour, and
              // a 60-stop wheel is unusable at this size.
              count: 4,
              step: 15,
              value: controller.minute.value,
              onChanged: controller.setMinute,
            ),
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatefulWidget {
  const _Wheel({
    required this.count,
    required this.value,
    required this.onChanged,
    this.step = 1,
  });

  final int count;
  final int step;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final FixedExtentScrollController _scroll =
      FixedExtentScrollController(initialItem: widget.value ~/ widget.step);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58.h,
      child: ListWheelScrollView.useDelegate(
        controller: _scroll,
        // 68 in the frame: rows at 141, 209 and 277.
        itemExtent: 68.v,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (i) => widget.onChanged(i * widget.step),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.count,
          builder: (context, i) {
            final focused = i * widget.step == widget.value;
            return Center(
              child: Text(
                (i * widget.step).toString().padLeft(2, '0'),
                style: focused
                    ? CustomTextStyles.slotWheelFocused
                    : CustomTextStyles.slotWheel,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The month, as `259:60133` pops it over the picker. Inline here rather than
/// a dialog: the frame draws it in the flow of the screen, between the wheels
/// and the repeat card.
/// "Everyday" over seven day circles.
class _RepeatCard extends StatelessWidget {
  const _RepeatCard();

  /// The frame's order — Sunday first, as its letters read S M T W T F S.
  static const _weekdays = [
    (DateTime.sunday, 'S'),
    (DateTime.monday, 'M'),
    (DateTime.tuesday, 'T'),
    (DateTime.wednesday, 'W'),
    (DateTime.thursday, 'T'),
    (DateTime.friday, 'F'),
    (DateTime.saturday, 'S'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SlotEditorController>();
    return Obx(
      () => Container(
        height: 109.v,
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.cardRim),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The frame ranges the word left and puts a calendar at the
            // right of the same line. The month grid used to sit open on the
            // page above; it belongs behind this glyph, as a dialog.
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: controller.toggleEveryday,
                    behavior: HitTestBehavior.opaque,
                    child:
                        Text('Everyday', style: CustomTextStyles.slotRepeat),
                  ),
                ),
                InkWell(
                  onTap: () => _pickDate(context, controller),
                  child: CustomImageView(
                    imagePath: ImageConstant.icCalendarOutline,
                    height: 22.h,
                    width: 22.h,
                    color: appTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.v),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (weekday, letter) in _weekdays) ...[
                  _DayCircle(
                    letter: letter,
                    selected: controller.repeatOn.contains(weekday),
                    onTap: () => controller.toggleDay(weekday),
                  ),
                  if (weekday != _weekdays.last.$1) SizedBox(width: 21.h),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The month grid, as the frame shows it — a centred card with the month and
/// its arrows, the dates, and Cancel / Done beneath a rule.
Future<void> _pickDate(
  BuildContext context,
  SlotEditorController controller,
) async {
  final chosen = await showDialog<DateTime>(
    context: context,
    builder: (context) {
      var month = DateTime(controller.day.value.year, controller.day.value.month);
      var picked = controller.day.value;
      return StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: appTheme.surface,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.h, 16.v, 16.h, 8.v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MonthCalendar draws no arrows, so the dialog carries its
                // own month row — the frame has one either side of the name.
                Row(
                  children: [
                    InkWell(
                      onTap: () => setState(
                        () => month = DateTime(month.year, month.month - 1),
                      ),
                      child: Icon(Icons.chevron_left,
                          size: 24.h, color: appTheme.textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy').format(month),
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.expertRowLabel,
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(
                        () => month = DateTime(month.year, month.month + 1),
                      ),
                      child: Icon(Icons.chevron_right,
                          size: 24.h, color: appTheme.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8.v),
                MonthCalendar(
                  month: month,
                  selected: picked,
                  onSelected: (date) => setState(() => picked = date),
                  showMonthLabel: false,
                  // Amber, as the frame marks the chosen day — not the brand
                  // blue the other calendars in the app use.
                  selectedColor: appTheme.daySelected,
                ),
                SizedBox(height: 8.v),
                Divider(height: 1.v, color: appTheme.cardRim),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel',
                            style: CustomTextStyles.expertRowLabel),
                      ),
                    ),
                    SizedBox(
                      height: 24.v,
                      child: VerticalDivider(
                        width: 1.h,
                        color: appTheme.cardRim,
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(picked),
                        child: Text('Done',
                            style: CustomTextStyles.expertRowLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  if (chosen != null) controller.selectDay(chosen);
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({
    required this.letter,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 23.1.h,
        height: 23.1.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // The frame marks none of the seven, so the chosen treatment is the
          // app's own.
          color: selected ? appTheme.actionFill : appTheme.surface,
          shape: BoxShape.circle,
          // No ring once it is filled: the fill is the state, and a hairline
          // around the blue read as an outline nobody asked for.
          border: selected ? null : Border.all(color: appTheme.cardRim),
        ),
        child: Text(
          letter,
          style: CustomTextStyles.slotDayLetter.copyWith(
            color: selected ? appTheme.onPrimary : null,
          ),
        ),
      ),
    );
  }
}
