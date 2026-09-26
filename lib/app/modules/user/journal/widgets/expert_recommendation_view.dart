import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/expert_recommendation.dart';
import 'session_card.dart';

/// The Journal's second tab — Figma "Expert Recommendation" (`259:60761`).
///
/// Sessions grouped under "Recent Live Sessions" and "Earlier Sessions", each
/// a card carrying the expert's note and the one thing they recommended.
/// Tapping a card opens that recommendation in full (`259:60842`).
///
/// Measured: the first heading at 178, its card at 212, the second heading at
/// 468 and its cards from 502 at a 248 pitch.
class ExpertRecommendationView extends StatelessWidget {
  const ExpertRecommendationView({
    super.key,
    required this.recent,
    required this.earlier,
    required this.onOpen,
  });

  /// The frame splits the list in two. Nothing in it says where the line
  /// falls, so "recent" is what is still unread — which is also what the
  /// tab's own count counts.
  final List<ExpertRecommendation> recent;
  final List<ExpertRecommendation> earlier;

  final ValueChanged<ExpertRecommendation> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(24.h, 26.v, 24.h, 32.v),
      children: [
        if (recent.isNotEmpty) ...[
          Text('Recent Live Sessions',
              style: CustomTextStyles.expertGroupHeading),
          SizedBox(height: 13.v),
          for (final item in recent) ...[
            SessionCard(recommendation: item, onTap: () => onOpen(item)),
            SizedBox(height: 16.v),
          ],
          SizedBox(height: 9.v),
        ],
        if (earlier.isNotEmpty) ...[
          Text('Earlier Sessions', style: CustomTextStyles.expertGroupHeading),
          SizedBox(height: 13.v),
          for (final item in earlier) ...[
            SessionCard(recommendation: item, onTap: () => onOpen(item)),
            SizedBox(height: 16.v),
          ],
        ],
      ],
    );
  }
}
