import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/mood.dart';
import '../../../widgets/month_calendar.dart';
import 'controller/checkin_controller.dart';

/// A check-in history — Figma "Profile/mood checkin" (page 124:2, `176:34264`
/// for the calendar, `176:34492` for a day's entry).
///
/// Two states, as the two frames are: months stacked in cards, each day a
/// filled circle with its number beneath; and, once a day carrying an entry is
/// picked, that entry on its own. The header's glyph switches with the state —
/// a menu on the calendar, a calendar on the entry, which is what returns.
///
/// Two things the frames get wrong and this does not:
///
/// - The frame's grid runs **ten** days to a row under a Mon..Sun header,
///   which those labels cannot describe. This keeps the real seven-column
///   week and takes only the circle-and-number treatment from it.
/// - The frames still draw the old nine-mood emoji. A recorded mood is the
///   slider's illustration now, so that is what fills a day's circle.
class CheckinScreen extends GetView<CheckinController> {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.v),
            Obx(() => _Header(
                  title: controller.kind.title,
                  showingEntry: controller.showingEntry.value,
                  onAction: controller.backToCalendar,
                )),
            Expanded(
              child: Obx(
                () => controller.showingEntry.value
                    ? const _EntryView()
                    : const _CalendarView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.showingEntry,
    required this.onAction,
  });

  final String title;
  final bool showingEntry;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
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
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: CustomTextStyles.appBarTitle,
            ),
          ),
          InkWell(
            onTap: showingEntry ? onAction : null,
            child: CustomImageView(
              imagePath: showingEntry
                  ? ImageConstant.icCalendarSearch
                  : ImageConstant.icMoreVertical,
              height: 22.h,
              width: showingEntry ? 20.h : 6.h,
              color: appTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckinController>();
    return Obx(() => ListView(
          padding: EdgeInsets.fromLTRB(24.h, 34.v, 24.h, 32.v),
          children: [
            for (final month in controller.months) ...[
              Container(
                padding: EdgeInsets.fromLTRB(23.h, 25.v, 23.h, 25.v),
                decoration: BoxDecoration(
                  color: appTheme.surface,
                  borderRadius: BorderRadius.circular(12.h),
                  border: Border.all(color: appTheme.calendarCardBorder),
                ),
                child: MonthCalendar(
                  month: month,
                  selected: controller.selected.value,
                  marked: controller.marked,
                  onSelected: controller.selectDate,
                  style: MonthCalendarStyle.circles,
                  markBuilder: (day) => controller.marked
                          .any((d) => DateUtils.isSameDay(d, day))
                      // Cropped to the head: at 20 across, a bust would be
                      // unreadable, and the face is what carries the mood.
                      ? Image.asset(
                          controller.figure.value
                              .artFor(controller.levelOn(day)),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        )
                      : null,
                ),
              ),
              SizedBox(height: 32.v),
            ],
          ],
        ));
  }
}

class _EntryView extends StatelessWidget {
  const _EntryView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckinController>();
    return Obx(() {
      final entry = controller.entry.value;
      if (entry == null) return const SizedBox.shrink();
      return ListView(
        // The card is inset 40, not the 24 the rest of the screen uses.
        padding: EdgeInsets.fromLTRB(40.h, 33.v, 40.h, 32.v),
        children: [
          _EntryCard(entry: entry, figure: controller.figure.value),
        ],
      );
    });
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.figure});

  final MoodEntry entry;
  final MoodFigure figure;

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    'Sunday',
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "Thursday, 4 Jul, 12:01 pm", as the frame prints it.
  String get _stamp {
    final when = entry.recordedAt;
    final h24 = when.hour;
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    final m = when.minute.toString().padLeft(2, '0');
    final ampm = h24 < 12 ? 'am' : 'pm';
    return '${_days[when.weekday - 1]}, ${when.day} '
        '${_months[when.month - 1]}, $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.h, 17.5.v, 10.h, 20.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.entryCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_stamp, style: CustomTextStyles.emptyStateBody),
          SizedBox(height: 26.v),
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  height: 22.h,
                  width: 22.h,
                  child: Image.asset(
                    figure.artFor(entry.level),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              SizedBox(width: 12.h),
              Text(entry.level.label, style: CustomTextStyles.statsHeading),
            ],
          ),
        ],
      ),
    );
  }
}
