import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/core/l10n/app_translations.dart';
import 'package:soothifyafrica/app/core/l10n/en.dart';
import 'package:soothifyafrica/app/core/l10n/pcm.dart';
import 'package:soothifyafrica/app/data/models/app_language.dart';
import 'package:soothifyafrica/app/data/models/app_tab.dart';
import 'package:soothifyafrica/app/data/models/expert_tab.dart';
import 'package:soothifyafrica/app/data/models/settings_entry.dart';
import 'package:soothifyafrica/app/data/models/studio_partner.dart';
import 'package:soothifyafrica/app/modules/practitioner/payouts/expert_payout_outcome_screen.dart';

/// The two catalogues, checked against each other.
///
/// A key used on a screen but missing from [en] is the one failure that
/// reaches a user as raw text — GetX prints the key itself. Pidgin is
/// allowed to trail, because English is the fallback.
void main() {
  test('every Pidgin key exists in English', () {
    final strays = pcm.keys.where((k) => !en.containsKey(k)).toList();
    expect(strays, isEmpty,
        reason: 'these would never be read: English has no such key');
  });

  test('no value is empty', () {
    for (final entry in {...en, ...pcm}.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('Pidgin says something different from English', () {
    // Some keys are deliberately identical — names, brands, "Continue" —
    // but the catalogue as a whole has to be a translation, not a copy.
    final translated = pcm.entries
        .where((e) => en[e.key] != null && en[e.key] != e.value)
        .length;
    expect(translated, greaterThan(pcm.length ~/ 3),
        reason: 'too few keys actually differ to call this a translation');
  });

  test('the locales the catalogues are keyed by are the ones offered', () {
    for (final language in AppLanguage.values) {
      final tag = '${language.locale.languageCode}_'
          '${language.locale.countryCode}';
      expect(['en_NG', 'pcm_NG'], contains(tag),
          reason: '${language.label} has no catalogue');
    }
  });

  test('every key a screen asks for is in the English catalogue', () {
    // The screens hold keys now, not words, and a mistyped key is invisible
    // until the screen is opened -- GetX answers an unknown key with the key
    // itself, so the reader sees `expert.payoutMehtod`. This reads the
    // source instead, which is cheaper than opening forty screens.
    //
    // Keys reached through a variable are not matched, which is why the
    // enums that hold them -- tabs, payout outcomes, arrival states -- spell
    // their keys out as literals next to the `.tr`.
    final asked = RegExp(r"'([a-z][A-Za-z]*(?:\.[A-Za-z]+)+)'\.tr\b");
    final missing = <String>{};

    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      for (final match in asked.allMatches(file.readAsStringSync())) {
        if (!en.containsKey(match.group(1))) {
          missing.add('${match.group(1)}  (${file.path})');
        }
      }
    }

    expect(missing, isEmpty,
        reason: 'these would print themselves to the reader:\n'
            '${missing.join('\n')}');
  });

  test('the enums that carry keys carry ones that exist', () {
    // Nothing else registers the catalogue outside a GetMaterialApp, and an
    // unregistered lookup answers every key with itself -- which is the very
    // thing this is checking for.
    Get.addTranslations(AppTranslations().keys);
    Get.locale = AppLanguage.english.locale;

    // These do not reach `.tr` through a literal, so the test above cannot
    // see them: each enum stores a key and translates it in a getter.
    for (final word in [
      ...AppTab.values.map((t) => t.label),
      ...ExpertTab.values.map((t) => t.label),
      ...PayoutOutcome.values.expand((o) => [o.title, o.body]),
      ...StudioArrival.values.map((a) => a.label),
      ...SettingsEntry.values.map((e) => e.label),
    ]) {
      // These are read after lookup, under the English locale, so each one
      // has to be something the English catalogue actually says. A key that
      // is not in there comes back as itself and fails here.
      expect(en.values, contains(word), reason: word);
    }
  });
}
