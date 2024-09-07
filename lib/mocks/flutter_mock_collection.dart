part of '../cake_flutter.dart';

class FlutterMockCollection extends MockCollection {
  final List<MockNavigationObserver> navigationMocks = [];

  MockNavigationObserver get navigator {
    if (navigationMocks.isEmpty) {
      throw CakeFlutterError(
        'No navigation mocks found.',
        hint:
            'You can set a navigation mock with setApp() or through FlutterTestOptions.',
        thrownOn: 'mocks.navigator',
      );
    }
    return navigationMocks.first;
  }

  List<NavigatorObserver> setNavigationMocks(SetupSettings settings) {
    if (settings.navigatorMocks.isNotEmpty) {
      navigationMocks.clear();
      navigationMocks.addAll(settings.navigatorMocks);
    }

    if (settings.includeNavigationObserver) {
      navigationMocks.clear();
      navigationMocks.add(MockNavigationObserver());
    }

    return navigationMocks
        .map<NavigatorObserver>((e) => e as NavigatorObserver)
        .toList();
  }

  @override
  void pause() {
    super.pause();
    for (var mock in navigationMocks) {
      mock.pause();
    }
  }

  @override
  void resume() {
    super.resume();
    for (var mock in navigationMocks) {
      mock.resume();
    }
  }

  @override
  void reset() {
    super.reset();
    for (var mock in navigationMocks) {
      mock.reset();
    }
  }

  void addAllFromOther(FlutterMockCollection other) {
    addAll(other);
    for (var mock in other.navigationMocks) {
      navigationMocks.add(mock);
    }
  }
}
