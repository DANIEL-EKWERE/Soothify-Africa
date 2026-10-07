import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/policy_section.dart';
import 'widgets/settings_header.dart';
import '../../../widgets/soothify_word.dart';

/// Which of the three content pages is showing.
enum PolicyPage {
  // The frame heads this one "About us"; the Settings row that opens it says
  // "About Us", and so does the copy the designer supplied, so that spelling
  // wins.
  about('About Us'),
  privacy('Privacy policy'),
  terms('Terms and condition');

  const PolicyPage(this.title);

  final String title;
}

/// About Us, Privacy policy and Terms and condition — Figma `259:37665`,
/// `259:37649` and `259:37633`.
///
/// **The three frames carry no content of their own.** Each is a copy of the
/// Delete Account screen (`259:37617`) with only its heading changed: all
/// three print "We're sorry to see you go." and a "Delete Account" button.
/// That is a duplication mistake in the file, not copy, so none of it is
/// reproduced here.
///
/// The copy therefore comes from the designer directly. About Us arrived on
/// 2026-10-03; the other two are still outstanding and show [pending] until
/// they land. [body] is the one place to add them.
class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key, this.only});

  /// Which page to show. The route passes it through [Get.arguments]; this
  /// overrides that, so the screen can be mounted directly.
  final PolicyPage? only;

  static const String pending =
      'This page is being written. It will be here shortly.';

  /// Printed under the title where the document carries one.
  static const Map<PolicyPage, String> lastUpdated = {
    PolicyPage.privacy: 'Last updated: September 2026',
    PolicyPage.terms: 'Last updated: September 2026',
  };

  static const Map<PolicyPage, List<PolicySection>> body = {
    PolicyPage.about: [
      PolicySection('Our Vision', [
        'Soothify is a premier digital wellness platform designed to bring '
            'high-end, intentional movement and mindfulness straight to your '
            'daily life. Rooted in expert-led Pilates and Yoga, our mission '
            'is to make elite wellness accessible, sustainable, and deeply '
            'resonant.',
      ]),
      PolicySection('Mindful Craftsmanship', [
        'Built for individuals who refuse to compromise on quality, Soothify '
            'combines world-class instruction, clean minimalist design, and '
            'culturally inclusive programming\u2014including local language '
            'support\u2014to create a truly immersive practice space. Whether '
            'you have ten minutes between meetings or an hour for deep '
            'restoration, Soothify moves at the rhythm of your life.',
      ]),
    ],
    PolicyPage.terms: [
      PolicySection('Terms of Use', [
        'Welcome to Soothify. By accessing our landing page or using our '
            'digital wellness ecosystem, you agree to comply with and be '
            'bound by the following terms. Please read them carefully.',
      ]),
      PolicySection('1. Acceptance of Terms', [
        'By visiting or interacting with our landing page, you agree to these '
            'Terms of Use. If you do not agree, please discontinue use of our '
            'platform.',
      ]),
      PolicySection('2. Purpose of the Platform', [
        'Soothify provides a digital wellness sanctuary combining guided '
            'movement (Pilates and yoga), editorial insights, and access to '
            'independent licensed experts. Our content and tools are designed '
            'for general wellness, mindfulness, and personal growth. They do '
            'not constitute formal medical advice, psychotherapy, or clinical '
            'treatment.',
      ]),
      PolicySection('3. User Conduct', [
        'You agree to use Soothify only for lawful purposes. You shall not '
            'attempt to compromise the security of the platform, scrape or '
            'extract proprietary content, or disrupt the user experience for '
            'others.',
      ]),
      PolicySection('4. Intellectual Property', [
        'All branding, logos, visual assets, text copy, layout designs, and '
            'media libraries associated with Soothify are the exclusive '
            'property of Soothify. Unauthorized reproduction, distribution, '
            'or commercial use is strictly prohibited.',
      ]),
      PolicySection('5. Limitation of Liability', [
        'Soothify is provided on an "as is" and "as available" basis. While '
            'we strive to maintain a secure and seamless experience, we do '
            'not guarantee uninterrupted access and are not liable for any '
            'direct or indirect damages arising from your use of the '
            'platform.',
      ]),
      PolicySection('6. Changes to Terms', [
        'We reserve the right to modify these terms at any time. Continued '
            'use of the landing page following any updates constitutes your '
            'acceptance of the revised terms.',
      ]),
    ],
    PolicyPage.privacy: [
      PolicySection('Privacy Policy', [
        'At Soothify, we value your privacy and are committed to protecting '
            'your personal information. This policy outlines what we collect '
            'and how we handle it.',
      ]),
      PolicySection('1. Information We Collect', [
        'Intake & Preference Data: Information you voluntarily share during '
            'onboarding or booking flows (such as language preference, '
            'wellness goals, and general experience levels) to help us tailor '
            'your experience and pair you with the right guides.',
        'Communication Data: Information provided when you reach out to us '
            'with inquiries or feedback.',
        'Technical Data: Basic, anonymized analytics regarding how visitors '
            'interact with our landing page to help us improve performance.',
      ]),
      PolicySection('2. How We Use Your Information', [
        'We use the data we collect solely to:',
        'Personalize your Soothify experience.',
        'Match you with appropriate wellness guides and licensed experts '
            'based on your intake responses.',
        'Send relevant updates regarding our MVP launch and platform features '
            '(if you have opted in).',
      ]),
      PolicySection('3. Data Sharing & Confidentiality', [
        'We do not sell, trade, or rent your personal information to third '
            'parties. Your intake responses and session details are kept '
            'strictly confidential between you and your matched guide.',
      ]),
      PolicySection('4. Data Security', [
        'We employ industry-standard administrative and technical safeguards '
            'to protect your personal data against unauthorized access, '
            'alteration, or disclosure.',
      ]),
      PolicySection('5. Your Choices', [
        'You may choose not to provide optional intake details, though '
            'certain customizations (such as expert matching) may be limited '
            'without them. You can request the deletion of your data at any '
            'time by contacting our team.',
      ]),
      PolicySection('6. Contact Us', [
        'If you have any questions regarding these Terms or our Privacy '
            'Policy, please reach out to us directly through our official '
            'communication channels.',
      ]),
    ],
  };

  PolicyPage get page =>
      only ??
      (Get.arguments is PolicyPage
          ? Get.arguments as PolicyPage
          : PolicyPage.about);

  @override
  Widget build(BuildContext context) {
    final sections = body[page] ?? const <PolicySection>[];
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsHeader(title: page.title),
            SizedBox(height: 16.v),
            if (lastUpdated[page] case final String stamp) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 23.h),
                child: Text(stamp,
                    style: CustomTextStyles.policyEffectiveDate),
              ),
              SizedBox(height: 16.v),
            ],
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(23.h, 0, 23.h, 32.v),
                children: [
                  if (sections.isEmpty)
                    SoothifyText(pending,
                        style: CustomTextStyles.settingsPageBody)
                  else
                    for (final section in sections) ...[
                      SoothifyText(
                        section.heading,
                        style: CustomTextStyles.settingsSectionHeading,
                      ),
                      SizedBox(height: 8.v),
                      for (final paragraph in section.paragraphs) ...[
                        SoothifyText(
                          paragraph,
                          style: CustomTextStyles.settingsPageBody,
                        ),
                        SizedBox(height: 12.v),
                      ],
                      SizedBox(height: 12.v),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
