import 'dart:ui';

import 'package:cake_flutter/flutter_extensions/cake_platform_dispatcher.dart';

class TestFlutterView implements FlutterView {
  final FlutterView _view;
  final CakePlatformDispatcher _dispatcher;
  final Display _display;

  TestFlutterView(
    this._view,
    this._dispatcher,
    this._display,
  );

  @override
  double get devicePixelRatio => _view.devicePixelRatio;

  @override
  Display get display => _display;

  @override
  List<DisplayFeature> get displayFeatures => _view.displayFeatures;

  @override
  GestureSettings get gestureSettings => _view.gestureSettings;

  @override
  ViewPadding get padding => _view.padding;

  @override
  Rect get physicalGeometry => _view.physicalGeometry;

  @override
  Size get physicalSize => _view.physicalSize;

  @override
  PlatformDispatcher get platformDispatcher => _dispatcher;

  @override
  void render(Scene scene) {
    _view.render(scene);
  }

  @override
  ViewPadding get systemGestureInsets => _view.systemGestureInsets;

  @override
  void updateSemantics(SemanticsUpdate update) {
    _view.updateSemantics(update);
  }

  @override
  int get viewId => _view.viewId;

  @override
  ViewPadding get viewInsets => _view.viewInsets;

  @override
  ViewPadding get viewPadding => _view.viewPadding;
}
