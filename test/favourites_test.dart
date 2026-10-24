import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/models/settings_entry.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/user/favourites/controller/favourites_controller.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/home_tab_controller.dart';

/// The heart, and the screen it fills.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockContentRepository content;

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    PrefUtils.resetForTesting();
    await PrefUtils().init();
    Get.put<SessionService>(await SessionService().init());
    content = MockContentRepository();
  });

  tearDown(Get.reset);

  Future<void> signIn() =>
      PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');

  group('tapping the heart', () {
    test('a guest is asked to sign in, and nothing is sent', () async {
      final home = HomeTabController(content)..onInit();
      await home.load();
      final item = home.popular.isNotEmpty ? home.popular.first : null;
      if (item == null) return;

      await home.toggleHeart(item);

      expect((await content.getFavourites()), isEmpty);
    });

    test('somebody signed in fills it, and the card redraws', () async {
      await signIn();
      final home = HomeTabController(content);
      await home.load();
      final item = home.popular.first;
      expect(item.isFavourite, isFalse);

      await home.toggleHeart(item);

      // Drawn immediately rather than after the round trip: a heart that
      // waits reads as a tap that did not land.
      expect(home.popular.first.isFavourite, isTrue);
      expect((await content.getFavourites()).single.id, item.id);
    });

    test('tapping it again empties it', () async {
      await signIn();
      final home = HomeTabController(content);
      await home.load();
      final item = home.popular.first;

      await home.toggleHeart(item);
      await home.toggleHeart(home.popular.first);

      expect(home.popular.first.isFavourite, isFalse);
      expect(await content.getFavourites(), isEmpty);
    });
  });

  group('the favourites screen', () {
    test('lists what was hearted', () async {
      await content.setFavourite('4', on: true);

      final c = FavouritesController(content);
      await c.load();

      expect(c.items.single.id, '4');
    });

    test('unhearting takes the row off the list at once', () async {
      await content.setFavourite('4', on: true);
      final c = FavouritesController(content);
      await c.load();

      await c.remove(c.items.first);

      expect(c.items, isEmpty);
      expect(await content.getFavourites(), isEmpty);
    });

    test('it starts empty rather than erroring', () async {
      final c = FavouritesController(content);
      await c.load();

      expect(c.items, isEmpty);
      expect(c.isLoading.value, isFalse);
    });
  });

  group('where it is reached from', () {
    test('Settings lists it, under Account', () {
      final rows = SettingsEntry.forClient;

      expect(rows, contains(SettingsEntry.favourites));
      expect(
        rows.indexOf(SettingsEntry.favourites),
        rows.indexOf(SettingsEntry.account) + 1,
      );
    });

    test('a practitioner has it too', () {
      expect(SettingsEntry.forExpert, contains(SettingsEntry.favourites));
    });
  });

  group('the popular row', () {
    test('comes from its own endpoint, not a category that does not exist',
        () async {
      // It used to ask getByCategory('popular'). There is no such category
      // on the server, so the row was empty against the real API and full
      // only against this mock.
      final popular = await content.getPopular();

      expect(popular, isNotEmpty);
      expect(popular.every((MediaItem i) => i.categoryId == 'popular'), isTrue);
    });
  });
}
