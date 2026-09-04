import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/services/session_service.dart';
import 'controller/practitioner_dashboard_controller.dart';

class PractitionerDashboardScreen
    extends GetView<PractitionerDashboardController> {
  const PractitionerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practitioner'),
        actions: [
          TextButton(
            onPressed: () async {
              await Get.find<SessionService>().signOut();
              Get.offAllNamed(AppRoutes.roleSelect);
            },
            child: const Text('Switch role'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.h),
          child: Text(
            'Practitioner tools land here once the designs are ready.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
