import 'package:flutter_test/flutter_test.dart';

import 'package:soothifyafrica/app/data/models/profile_stats.dart';
import 'package:soothifyafrica/app/data/models/user_profile.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/profile_repository.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/home_tab_controller.dart';

/// The Home header's greeting.
///
/// The frame draws "Hi, Dera". That name shipped as a literal, so every
/// signed-in person was greeted as Dera.
class _Profiles implements ProfileRepository {
  _Profiles(this.name, {this.fails = false});

  final String name;
  final bool fails;

  @override
  Future<UserProfile> me() async {
    if (fails) throw Exception('offline');
    return UserProfile(id: '1', fullName: name, email: 'x@example.com');
  }

  @override
  Future<ProfileStats> getStats() async => ProfileStats.empty;

  @override
  Future<UserProfile> update({
    String? fullName,
    String? language,
    String? moodFigure,
    String? communityHandle,
  }) async =>
      me();

  @override
  Future<UserProfile> uploadAvatar(String filePath) async => me();
}

void main() {
  DateTime morning() => DateTime(2024, 7, 15, 9, 41);

  HomeTabController build(ProfileRepository? profiles) => HomeTabController(
        MockContentRepository(),
        profiles: profiles,
        now: morning,
      );

  test('it uses the signed-in person\'s own first name', () async {
    final c = build(_Profiles('Chidera Obi'))..onInit();
    await Future<void>.delayed(Duration.zero);

    expect(c.hello, 'Hi, Chidera');
  });

  test('a one-word name is used whole', () async {
    final c = build(_Profiles('Ada'))..onInit();
    await Future<void>.delayed(Duration.zero);

    expect(c.hello, 'Hi, Ada');
  });

  test('before the name arrives it greets the time of day', () {
    final c = build(_Profiles('Chidera Obi'));

    // Not a placeholder name: being told good morning is no worse than
    // usual, being called by a stranger's name is.
    expect(c.hello, 'Good morning');
  });

  test('a profile that cannot be read still gets a greeting', () async {
    final c = build(_Profiles('', fails: true))..onInit();
    await Future<void>.delayed(Duration.zero);

    expect(c.hello, 'Good morning');
  });

  test('an account with no name on it falls back too', () async {
    final c = build(_Profiles('   '))..onInit();
    await Future<void>.delayed(Duration.zero);

    expect(c.hello, 'Good morning');
  });

  test('no profile repository at all is fine', () {
    expect(build(null).hello, 'Good morning');
  });
}
