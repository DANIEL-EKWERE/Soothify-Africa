import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/kyc_question.dart';

/// The age picker — Figma 2214:25651.
///
/// The design centres the chosen value in a 312x36 outlined box at 24px, with
/// neighbours at 14px and half opacity, 37 apart. A wheel gives that for free
/// and keeps the interaction natural on a long list.
class AgeWheel extends StatefulWidget {
  const AgeWheel({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<KycOption> options;
  final String? selectedValue;
  final ValueChanged<KycOption> onSelected;

  @override
  State<AgeWheel> createState() => _AgeWheelState();
}

class _AgeWheelState extends State<AgeWheel> {
  late final FixedExtentScrollController _controller;

  int get _initialIndex {
    final i = widget.options.indexWhere((o) => o.value == widget.selectedValue);
    // Nothing chosen yet: the design shows 20 centred, which is index 2.
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 296.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The selection marker sits behind the wheel so the centred value
          // reads as boxed, as in the design.
          Container(
            height: 36.h,
            width: 312.h,
            decoration: BoxDecoration(
              color: appTheme.surface,
              border: Border.all(color: appTheme.soothifyBlue),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 37.h,
            diameterRatio: 100,
            perspective: 0.001,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) => widget.onSelected(widget.options[i]),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.options.length,
              builder: (context, i) {
                final option = widget.options[i];
                final isSelected = option.value == widget.selectedValue;
                return Center(
                  child: Text(
                    option.label,
                    style: isSelected
                        ? CustomTextStyles.wheelSelected
                        : CustomTextStyles.wheelItem,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
