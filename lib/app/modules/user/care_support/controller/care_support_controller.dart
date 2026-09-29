import 'package:get/get.dart';

import '../../../../data/models/care_concern.dart';

/// Drives the Care Support report — Figma `280:26747`, and `280:26775` once
/// it has been sent.
class CareSupportController extends GetxController {
  final Rxn<CareConcern> concern = Rxn<CareConcern>();

  /// True once "Send to Support Team" has been pressed.
  final RxBool sent = false.obs;

  List<CareConcern> get concerns => CareConcern.values;

  bool isSelected(CareConcern c) => concern.value == c;

  void choose(CareConcern c) => concern.value = c;

  /// One reason, not several: the frame draws a single blue outline.
  bool get canSend => concern.value != null;

  void send() {
    if (!canSend) return;
    sent.value = true;
  }
}
