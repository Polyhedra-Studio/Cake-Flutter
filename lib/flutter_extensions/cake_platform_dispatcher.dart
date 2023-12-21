import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cake_flutter/flutter_extensions/test_display.dart';
import 'package:cake_flutter/flutter_extensions/test_flutter_view.dart';
import 'package:cake_flutter/flutter_test_options.dart';
import 'package:cake_flutter/test_platform.dart';
import 'package:flutter/widgets.dart';

class CakePlatformDispatcher implements PlatformDispatcher {
  final PlatformDispatcher dispatcher;
  final TestPlatform _platform;
  final Map<int, TestFlutterView> _views = {};
  final Display _display;
  final FlutterTestOptions options;

  CakePlatformDispatcher({
    required this.options,
    required this.dispatcher,
  })  : _platform = options.platform ?? TestPlatform(),
        _display =
            TestDisplay(options.mediaQueryData ?? const MediaQueryData()) {
    _updateViews();
  }

  TestFlutterView _wrapView(FlutterView view) {
    return TestFlutterView(view, this, _display);
  }

  void _updateViews() {
    final List<Object> extraViewKeys = <Object>[..._views.keys];

    for (final FlutterView view in dispatcher.views) {
      extraViewKeys.remove(view.viewId);
      if (!_views.containsKey(view.viewId)) {
        _views[view.viewId] = _wrapView(view);
      }
    }

    extraViewKeys.forEach(_views.remove);
  }

  void render(Scene scene, [FlutterView? view]) {
    if (view != null) {
      _views[view.viewId] = _wrapView(view);
    }
  }

  @override
  Locale get locale => _platform.locale;

  @override
  List<Locale> get locales => _platform.locales;

  @override
  FlutterView? view({required int id}) {
    return _views[id];
  }

  @override
  Iterable<FlutterView> get views => _views.values;

  @override
  FlutterView? get implicitView => dispatcher.implicitView != null
      ? _views[dispatcher.implicitView!.viewId]
      : _views[0];

  TestFlutterView get defaultView => implicitView as TestFlutterView;

  // --- Calls through ---

  @override
  void sendPortPlatformMessage(
    String name,
    ByteData? data,
    int identifier,
    Object? port,
  ) {
    dispatcher.sendPortPlatformMessage(
      name,
      data,
      identifier,
      port as SendPort,
    );
  }

  @override
  void sendPlatformMessage(
    String name,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {
    dispatcher.sendPlatformMessage(name, data, callback);
  }

  @override
  String get defaultRouteName => dispatcher.defaultRouteName;

  @override
  Brightness get platformBrightness => dispatcher.platformBrightness;

  @override
  bool get semanticsEnabled => dispatcher.semanticsEnabled;

  @override
  String? get systemFontFamily => dispatcher.systemFontFamily;

  @override
  double get textScaleFactor => dispatcher.textScaleFactor;

  @override
  String get initialLifecycleState => dispatcher.initialLifecycleState;

  @override
  AccessibilityFeatures get accessibilityFeatures =>
      dispatcher.accessibilityFeatures;

  @override
  bool get alwaysUse24HourFormat => dispatcher.alwaysUse24HourFormat;

  @override
  bool get brieflyShowPassword => dispatcher.brieflyShowPassword;

  @override
  Locale? computePlatformResolvedLocale(List<Locale> supportedLocales) {
    return _platform.locale;
  }

  @override
  Iterable<Display> get displays => [_display];

  @override
  FrameData get frameData => dispatcher.frameData;

  @override
  ByteData? getPersistentIsolateData() {
    return dispatcher.getPersistentIsolateData();
  }

  @override
  bool get nativeSpellCheckServiceDefined =>
      dispatcher.nativeSpellCheckServiceDefined;

  @override
  void registerBackgroundIsolate(RootIsolateToken token) {
    dispatcher.registerBackgroundIsolate(token);
  }

  @override
  void requestDartPerformanceMode(DartPerformanceMode mode) {
    dispatcher.requestDartPerformanceMode(mode);
  }

  @override
  void scheduleFrame() {
    dispatcher.scheduleFrame();
  }

  @override
  void setIsolateDebugName(String name) {
    dispatcher.setIsolateDebugName(name);
  }

  @override
  void updateSemantics(SemanticsUpdate update) {
    dispatcher.updateSemantics(update);
  }

  // --- EMPTY STUBS ---
  @override
  VoidCallback? onAccessibilityFeaturesChanged;

  @override
  FrameCallback? onBeginFrame;

  @override
  VoidCallback? onDrawFrame;

  @override
  ErrorCallback? onError;

  @override
  VoidCallback? onFrameDataChanged;

  @override
  KeyDataCallback? onKeyData;

  @override
  VoidCallback? onLocaleChanged;

  @override
  VoidCallback? onMetricsChanged;

  @override
  VoidCallback? onPlatformBrightnessChanged;

  @override
  VoidCallback? onPlatformConfigurationChanged;

  @override
  PlatformMessageCallback? onPlatformMessage;

  @override
  PointerDataPacketCallback? onPointerDataPacket;

  @override
  TimingsCallback? onReportTimings;

  @override
  SemanticsActionEventCallback? onSemanticsActionEvent;

  @override
  VoidCallback? onSemanticsEnabledChanged;

  @override
  VoidCallback? onSystemFontFamilyChanged;

  @override
  VoidCallback? onTextScaleFactorChanged;
}
