import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/environment_vibe.dart';
import '../controller/ai_hub_controller.dart';
import 'breathing_scene.dart';

/// The expanded AI Hub — Figma "AI Hub | Expanded | Chat" (`176:56395`).
///
/// The same scene, now full-bleed, with the conversation over it. Guide lines
/// sit left in white; the user's sit right in the brand blue.
class GuideChat extends StatefulWidget {
  const GuideChat({super.key});

  @override
  State<GuideChat> createState() => _GuideChatState();
}

class _GuideChatState extends State<GuideChat> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send(AiHubController controller) {
    controller.send(_input.text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiHubController>();
    return Stack(
      children: [
        Positioned.fill(
          child: Obx(
            () => BreathingSceneLoop(playing: controller.playing.value),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              SizedBox(height: 27.v),
              _Header(onClose: controller.collapse),
              SizedBox(height: 12.v),
              Container(
                height: 1.v,
                margin: EdgeInsets.symmetric(horizontal: 24.h),
                color: appTheme.onPrimary.withValues(alpha: 0.25),
              ),
              Expanded(
                child: Obx(() => ListView.separated(
                      padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 20.v),
                      itemCount: controller.messages.length,
                      separatorBuilder: (_, _) => SizedBox(height: 8.v),
                      itemBuilder: (context, i) =>
                          _Bubble(message: controller.messages[i]),
                    )),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.h, 0, 10.h, 22.v),
                child: _Composer(
                  input: _input,
                  onSend: () => _send(controller),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          // The frame marks the guide as live with a small green dot.
          Container(
            height: 8.h,
            width: 8.h,
            decoration: BoxDecoration(
              color: appTheme.success,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.h),
          Expanded(
            child: Text('Wellness Guide', style: CustomTextStyles.guideName),
          ),
          InkWell(
            onTap: onClose,
            customBorder: const CircleBorder(),
            child: Container(
              height: 28.h,
              width: 28.h,
              decoration: BoxDecoration(
                color: appTheme.onPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18.h,
                color: appTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final GuideMessage message;

  @override
  Widget build(BuildContext context) {
    final guide = message.fromGuide;
    return Align(
      alignment: guide ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        // 237 of the 342 content width, so a long line wraps rather than
        // running the full width and losing the sense of a conversation.
        constraints: BoxConstraints(maxWidth: 237.h),
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.v),
        decoration: BoxDecoration(
          color: guide ? appTheme.onPrimary : appTheme.soothifyBlue,
          borderRadius: BorderRadius.circular(16.h),
        ),
        child: Text(
          message.text,
          style: guide
              ? CustomTextStyles.guideBubble
              : CustomTextStyles.guideBubbleOwn,
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.input, required this.onSend});

  final TextEditingController input;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.v,
      padding: EdgeInsets.fromLTRB(24.h, 0, 8.h, 0),
      decoration: BoxDecoration(
        color: appTheme.onPrimary,
        borderRadius: BorderRadius.circular(28.h),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: input,
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
              style: CustomTextStyles.guideBubble,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Ask anything...',
                hintStyle: CustomTextStyles.guideComposerHint,
              ),
            ),
          ),
          InkWell(
            onTap: onSend,
            customBorder: const CircleBorder(),
            child: Container(
              height: 38.h,
              width: 38.h,
              decoration: BoxDecoration(
                color: appTheme.lockCircle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward,
                size: 20.h,
                color: appTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
