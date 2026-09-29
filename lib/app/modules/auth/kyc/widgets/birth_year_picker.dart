import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/kyc_question.dart';

/// "What is your age?" — Figma `259:27860`, which replaced the plain age
/// wheel the questionnaire used to end on.
///
/// Two halves on one axis: a readout on the left — "Age", the number, "yrs" —
/// and a wheel of birth years on the right. The user picks the year; the age
/// is derived, never typed.
///
/// **Measured off a 2x render, not the node JSON** (`img_259_27860.png`; the
/// `nodes` quota was spent and only the image endpoint answered). Left column
/// left-aligned from x=53, wheel centred at x=281, the selected year in a
/// 90x37 outlined box. Anything here to a fraction of a pixel is a reading of
/// a bitmap, so re-measure against the JSON when a budget returns.
///
/// The frame prints "20" beside a boxed 1993, which cannot both be true —
/// the readout is a static placeholder there. This one computes.
class BirthYearPicker extends StatefulWidget {
  const BirthYearPicker({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.currentYear,
    required this.onSelected,
  });

  final List<KycOption> options;
  final String? selectedValue;

  /// What the age is measured against — injected so a golden does not change
  /// its mind on New Year's Day.
  final int currentYear;

  final ValueChanged<KycOption> onSelected;

  @override
  State<BirthYearPicker> createState() => _BirthYearPickerState();
}

class _BirthYearPickerState extends State<BirthYearPicker> {
  late final FixedExtentScrollController _controller;

  int get _initialIndex {
    final i = widget.options.indexWhere((o) => o.value == widget.selectedValue);
    // Nothing chosen yet: the frame opens part-way down the list rather than
    // at the youngest year, so the wheel reads as scrollable in both
    // directions. Index 2 is the third year offered.
    return i == -1 ? 2 : i;
  }

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: _initialIndex);
    // A wheel always has something under the marker, so record that value
    // immediately rather than leaving the question unanswered.
    if (widget.selectedValue == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onSelected(widget.options[_initialIndex]);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The year under the marker, which is what the readout reports. Falls back
  /// to the initial index so the left half is never blank on first paint —
  /// the frame draws a number there before anything has been touched.
  String get _year =>
      widget.selectedValue ?? widget.options[_initialIndex].value;

  @override
  Widget build(BuildContext context) {
    // Centred, not bare: the screen hands this an Expanded, whose tight
    // height would otherwise swallow the SizedBox and stretch the wheel to
    // ten years where the frame shows six.
    return Center(
      child: SizedBox(
        height: 296.v,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 29.h),
            Expanded(
              child: _Readout(year: _year, currentYear: widget.currentYear),
            ),
            SizedBox(
              width: 170.h,
              child: _YearWheel(state: this),
            ),
          ],
        ),
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.year, required this.currentYear});

  final String year;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Age', style: CustomTextStyles.ageReadoutLabel),
        SizedBox(height: 22.v),
        Text(
          '${KycQuestion.ageFor(year, currentYear)}',
          style: CustomTextStyles.ageReadoutValue,
        ),
        SizedBox(height: 22.v),
        Text('yrs', style: CustomTextStyles.ageReadoutLabel),
      ],
    );
  }
}

class _YearWheel extends StatelessWidget {
  const _YearWheel({required this.state});

  final _BirthYearPickerState state;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget;
    return Stack(
      alignment: Alignment.center,
      children: [
        // The marker sits behind the wheel so the centred year reads as
        // boxed, as in the frame. Rounded here where the old full-width age
        // marker was square — the render shows a clear radius on it.
        Container(
          height: 37.v,
          width: 90.h,
          decoration: BoxDecoration(
            color: appTheme.surface,
            border: Border.all(color: appTheme.soothifyBlue),
            borderRadius: BorderRadius.circular(8.h),
          ),
        ),
        ListWheelScrollView.useDelegate(
          controller: state._controller,
          itemExtent: 45.v,
          diameterRatio: 100,
          perspective: 0.001,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (i) => widget.onSelected(widget.options[i]),
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.options.length,
            builder: (context, i) {
              final option = widget.options[i];
              final isSelected = option.value == state._year;
              return Center(
                child: Text(
                  option.label,
                  style: isSelected
                      ? CustomTextStyles.yearWheelSelected
                      : CustomTextStyles.yearWheelItem,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
