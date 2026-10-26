import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../data/models/booked_session.dart' show ExpertPeer;
import '../../../../widgets/gradient_text.dart';
import '../controller/booking_controller.dart';
import '../../../../widgets/soothify_word.dart';

/// The matched coach's profile — Figma "Matched with instructor" (135:20932).
///
/// The celebration frame (135:21320, `259:31992` in the current file) carries
/// identical copy, and the calendar frame (135:21450) is this screen with a
/// date sheet over its lower half — so all three are this one view, with the
/// sheet raised on demand and the celebration drawn over it by
/// [ConfettiOverlay] the first time matching completes.
class MatchedView extends StatelessWidget {
  const MatchedView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    final coach = controller.coach;
    return ListView(
      padding: EdgeInsets.only(bottom: 32.v),
      children: [
        SizedBox(height: 51.v),
        Text('Awesome! You matched with',
            style: CustomTextStyles.matchedLead),
        SizedBox(height: 46.v),
        GradientText(
          coach.name,
          gradient: appTheme.authHeaderGradient,
          style: CustomTextStyles.coachName,
        ),
        SizedBox(height: 8.v),
        // The badge sits on the photo's lower edge, centred — not in a row of
        // its own beneath it.
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomImageView(
              // Their own portrait where the server has one; the frame's
              // photo is the fallback, not the default.
              imagePath: coach.avatarUrl.isNotEmpty
                  ? coach.avatarUrl
                  : ImageConstant.imgCoachPhoto,
              height: 258.v,
              width: double.infinity,
              fit: BoxFit.cover,
              radius: BorderRadius.circular(8.h),
            ),
            Positioned(
              bottom: -2.v,
              child: _MatchBadge(percent: coach.matchPercent),
            ),
          ],
        ),
        SizedBox(height: 22.v),
        Text(coach.blurb, style: CustomTextStyles.coachBlurb),
        SizedBox(height: 32.v),
        // This block is centred in the frame — the heading, both chip rows
        // and the peer avatars. Everything above and below it is flush left.
        Text(
          'Because you feel...',
          textAlign: TextAlign.center,
          style: CustomTextStyles.coachSection,
        ),
        SizedBox(height: 8.v),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.h,
          runSpacing: 9.v,
          children: [
            for (final feeling in coach.feelings) _InterestChip(feeling),
          ],
        ),
        SizedBox(height: 27.v),
        Text(
          'Other Instructor Matches',
          textAlign: TextAlign.center,
          style: CustomTextStyles.coachSection,
        ),
        SizedBox(height: 8.v),
        // The other people the server actually ranked. This drew a fixed
        // set of asset portraits -- the same five strangers whoever you
        // were paired with -- and falls back to them only when there is no
        // server to ask, which is the no-backend build and the goldens.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: coach.peers.isEmpty
              ? [
                  for (final peer in ImageConstant.imgCoachPeers) ...[
                    ClipOval(
                      child: CustomImageView(
                        imagePath: peer,
                        height: 46.h,
                        width: 46.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (peer != ImageConstant.imgCoachPeers.last)
                      SizedBox(width: 12.h),
                  ],
                ]
              : [
                  for (final peer in coach.peers) ...[
                    _PeerFace(peer: peer),
                    if (peer != coach.peers.last) SizedBox(width: 12.h),
                  ],
                ],
        ),
        SizedBox(height: 30.v),
        Text('About ${coach.name}', style: CustomTextStyles.matchedLead),
        SizedBox(height: 16.v),
        _Detail(heading: 'Signature quote', lines: [coach.quote]),
        SizedBox(height: 16.v),
        _Detail(heading: 'Outside of Soothify', lines: coach.outside),
        SizedBox(height: 16.v),
        // The redrawn screen runs Signature quote -> Outside of Soothify ->
        // Expertise in. The "Find <name>" row of social glyphs it used to
        // carry between the last two is gone from the frame.
        _Detail(heading: 'Expertise in', lines: coach.expertise),
        // Their own library, credited to them by the upload form's
        // practitioner link. Left out entirely when they have published
        // nothing: a heading over an empty rail reads as a failed load,
        // and the frame's three placeholder cards were worse -- they named
        // content that did not exist.
        if (coach.videos.isNotEmpty || coach.videoTitles.isNotEmpty) ...[
          SizedBox(height: 26.v),
          Text(
            '${coach.name.split(' ').first}’s Trending Videos',
            style: CustomTextStyles.matchedLead,
          ),
          SizedBox(height: 16.v),
          SizedBox(
            height: 168.v,
            child: coach.videos.isNotEmpty
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: coach.videos.length,
                    separatorBuilder: (_, _) => SizedBox(width: 16.h),
                    itemBuilder: (context, i) => _VideoCard(
                      title: coach.videos[i].title,
                      coverUrl: coach.videos[i].cover,
                      onTap: () => openMedia(
                        coach.videos[i],
                        source: 'Matched with ${coach.name}',
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: coach.videoTitles.length,
                    separatorBuilder: (_, _) => SizedBox(width: 16.h),
                    itemBuilder: (context, i) =>
                        _VideoCard(title: coach.videoTitles[i]),
                  ),
          ),
        ],
        SizedBox(height: 34.v),
        // One action, not the old "Get started" / "Schedule for later" pair.
        _PrimaryButton(
          label: 'Book a Session',
          onTap: controller.bookSession,
        ),
      ],
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    // No `alignment` on the Container: setting one makes it expand to the
    // largest allowed size, which stretched the badge across the screen
    // instead of hugging "98% Match".
    return Container(
        height: 24.v,
        padding: EdgeInsets.symmetric(horizontal: 10.h),
        decoration: BoxDecoration(
          color: appTheme.textPrimary,
          borderRadius: BorderRadius.circular(4.h),
        ),
      child: Center(
        widthFactor: 1,
        child: Text('$percent% Match', style: CustomTextStyles.matchBadge),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    // Same as the badge: an alignment here would stretch each chip to the
    // full row width and stack them one per line.
    return Container(
      height: 24.v,
      padding: EdgeInsets.symmetric(horizontal: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(label, style: CustomTextStyles.coachChip),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.heading, required this.lines});

  final String heading;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoothifyText(heading, style: CustomTextStyles.coachHeading),
        SizedBox(height: 4.v),
        for (final line in lines)
          Padding(
            padding: EdgeInsets.only(bottom: 4.v),
            child: Text(line, style: CustomTextStyles.coachBlurb),
          ),
      ],
    );
  }
}

/// One of the other people who also matched.
class _PeerFace extends StatelessWidget {
  const _PeerFace({required this.peer});

  final ExpertPeer peer;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CustomImageView(
        // Their own portrait where they have uploaded one; the frame's
        // first placeholder where they have not, so the row keeps its
        // shape rather than showing a gap.
        imagePath: peer.avatarUrl.isNotEmpty
            ? peer.avatarUrl
            : ImageConstant.imgCoachPeers.first,
        height: 46.h,
        width: 46.h,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.title, this.coverUrl = '', this.onTap});

  final String title;

  /// The item's own cover. Empty falls back to the frame's still.
  final String coverUrl;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
      width: 206.h,
      height: 168.v,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomImageView(
              imagePath:
                  coverUrl.isNotEmpty ? coverUrl : ImageConstant.imgCoachVideo,
              fit: BoxFit.cover,
              radius: BorderRadius.circular(8.h),
            ),
          ),
          Positioned(
            left: 8.h,
            top: 8.v,
            child: Container(
              height: 15.v,
              padding: EdgeInsets.symmetric(horizontal: 10.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.onPrimary,
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Text(title, style: CustomTextStyles.pillLabel),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 52.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.actionFill,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Text(
          label,
          style: CustomTextStyles.subscribeLabel,
        ),
      ),
    );
  }
}
