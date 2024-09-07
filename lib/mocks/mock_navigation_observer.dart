part of '../cake_flutter.dart';

class MockNavigationObserver extends NavigatorObserver {
  final String id = Random().nextInt(10000).toString();
  final MockableFunction onPush = MockableFunction();
  final MockableFunction onPop = MockableFunction();
  final MockableFunction onRemove = MockableFunction();
  final MockableFunction onReplace = MockableFunction();

  void reset() {
    onPush.reset();
    onPop.reset();
    onRemove.reset();
    onReplace.reset();
  }

  void pause() {
    onPush.pause();
    onPop.pause();
    onRemove.pause();
    onReplace.pause();
  }

  void resume() {
    onPush.resume();
    onPop.resume();
    onRemove.resume();
    onReplace.resume();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    onPush.call([route, previousRoute]);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop.call([route, previousRoute]);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    onRemove.call([route, previousRoute]);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    onReplace.call([newRoute, oldRoute]);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
