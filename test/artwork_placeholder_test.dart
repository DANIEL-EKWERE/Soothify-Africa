import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soothifyafrica/app/core/app_export.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/widgets/content_pills.dart';

import 'helpers.dart';

/// The cover on every content card.
///
/// It drew with Image.asset, which fails on every http URL — so once the
/// library came from the API rather than from the bundle, every card on
/// Discovery, the home rails and Recommended showed the grey block.
void main() {
  Future<void> mount(WidgetTester tester, String? path) async {
    useDesignFrame(tester);
    await pumpScreen(
      tester,
      Center(
        child: ArtworkPlaceholder(width: 150, height: 100, assetPath: path),
      ),
    );
  }

  testWidgets('a cover is drawn by the widget that knows every source',
      (tester) async {
    await mount(tester, 'https://soothifyafrica.com.ng/api/v1/media/x.jpeg/');
    expect(
      find.descendant(
        of: find.byType(ArtworkPlaceholder),
        matching: find.byType(CustomImageView),
      ),
      findsOneWidget,
      reason: 'a network cover cannot go through Image.asset',
    );
  });

  testWidgets('a bundled cover still draws', (tester) async {
    await mount(tester, 'assets/images/content/breath_work.png');
    expect(
      find.descendant(
        of: find.byType(ArtworkPlaceholder),
        matching: find.byType(CustomImageView),
      ),
      findsOneWidget,
    );
  });

  testWidgets('no cover is the flat block, at the card’s size',
      (tester) async {
    await mount(tester, null);
    expect(find.byType(CustomImageView), findsNothing);
    expect(tester.getSize(find.byType(ArtworkPlaceholder)),
        const Size(150, 100));
  });

  test('an item served by the API covers itself with its url', () {
    final item = MediaItem.fromJson(const {
      'id': 1,
      'title': 'test title',
      'media_type': 'video',
      'cover_url': 'https://soothifyafrica.com.ng/api/v1/media/x.jpeg/',
    });
    expect(item.coverAsset, isEmpty);
    expect(item.cover, item.coverUrl);
  });
}
