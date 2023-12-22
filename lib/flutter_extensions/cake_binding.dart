import 'package:cake_flutter/flutter_extensions/cake_platform_dispatcher.dart';
import 'package:cake_flutter/flutter_extensions/cake_render_object_to_widget_element.dart';
import 'package:cake_flutter/flutter_extensions/test_view_widget.dart';
import 'package:cake_flutter/flutter_test_options.dart';
import 'package:cake_flutter/widget_tree.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CakeBinding extends BindingBase
    with
        SchedulerBinding,
        ServicesBinding,
        GestureBinding,
        SemanticsBinding,
        RendererBinding,
        PaintingBinding,
        WidgetsBinding {
  @override
  CakePlatformDispatcher platformDispatcher;
  final MediaQueryData _mediaQueryData;

  bool _readyToProduceFrames = false;
  CakeRenderObjectToWidgetElement? _rootElement;

  CakeBinding([FlutterTestOptions? options])
      : platformDispatcher = CakePlatformDispatcher(
          options: options ?? const FlutterTestOptions(),
          dispatcher: PlatformDispatcher.instance,
        ),
        _mediaQueryData = options?.mediaQueryData ?? const MediaQueryData();

  Future<void> setRoot(
    Widget root, {
    required WidgetTreeBuilder onBuild,
  }) async {
    final TestView newRoot = wrapWithDefaultTestView(root, onBuild: onBuild);
    attachTestRootWidget(newRoot, onBuild: onBuild);
    scheduleFrame();
    drawFrame();
  }

  Future<void> forward({Duration duration = Duration.zero}) async {
    drawFrame();
    await Future.delayed(duration);
    //     return TestAsyncUtils.guard<void>(() {
    //   assert(inTest);
    //   assert(_clock != null);
    //   if (duration != null) {
    //     _currentFakeAsync!.elapse(duration);
    //   }
    //   _phase = newPhase;
    //   if (hasScheduledFrame) {
    //     _currentFakeAsync!.flushMicrotasks();
    //     handleBeginFrame(Duration(
    //       milliseconds: _clock!.now().millisecondsSinceEpoch,
    //     ));
    //     _currentFakeAsync!.flushMicrotasks();
    //     handleDrawFrame();
    //   }
    //   _currentFakeAsync!.flushMicrotasks();
    //   return Future<void>.value();
    // });
  }

  void _handleDrawFrame() {
    // assert(_schedulerPhase == SchedulerPhase.midFrameMicrotasks);
    // _frameTimelineTask?.finish(); // end the "Animate" phase
    // try {
    //   // PERSISTENT FRAME CALLBACKS
    //   _schedulerPhase = SchedulerPhase.persistentCallbacks;
    //   for (final FrameCallback callback in _persistentCallbacks) {
    //     _invokeFrameCallback(callback, _currentFrameTimeStamp!);
    //   }

    //   // POST-FRAME CALLBACKS
    //   _schedulerPhase = SchedulerPhase.postFrameCallbacks;
    //   final List<FrameCallback> localPostFrameCallbacks =
    //       List<FrameCallback>.of(_postFrameCallbacks);
    //   _postFrameCallbacks.clear();
    //   for (final FrameCallback callback in localPostFrameCallbacks) {
    //     _invokeFrameCallback(callback, _currentFrameTimeStamp!);
    //   }
    // } finally {
    //   _schedulerPhase = SchedulerPhase.idle;
    //   _frameTimelineTask?.finish(); // end the Frame
    //   assert(() {
    //     if (debugPrintEndFrameBanner) {
    //       debugPrint('▀' * _debugBanner!.length);
    //     }
    //     _debugBanner = null;
    //     return true;
    //   }());
    //   _currentFrameTimeStamp = null;
    // }
  }

  // -- Overrides --
  @override
  ViewConfiguration createViewConfiguration() {
    return ViewConfiguration(
      size: _mediaQueryData.size,
      devicePixelRatio: _mediaQueryData.devicePixelRatio,
    );
  }

  // Mirrors behavior in WidgetsBinding.wrapWithDefaultView
  TestView wrapWithDefaultTestView(
    Widget rootWidget, {
    required WidgetTreeBuilder onBuild,
  }) {
    return TestView(
      flutterView: platformDispatcher.defaultView,
      onBuild: onBuild,
      child: rootWidget,
    );
  }

  // Mirrors behavior in WidgetsBinding.attachRootWidget
  void attachTestRootWidget(
    TestView rootWidget, {
    required WidgetTreeBuilder onBuild,
  }) {
    assert(!isRootWidgetAttached, 'setApp() has already been run.');

    _readyToProduceFrames = true;
    final widgetAdapter = CakeRenderObjectToWidgetAdapter<RenderBox>(
      container: renderView,
      debugShortDescription: '[root]',
      onBuild: onBuild,
      child: rootWidget,
    );
    _rootElement = widgetAdapter.attachToTestRenderTree(buildOwner!, null);
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  bool get isRootWidgetAttached => _rootElement != null;

  @override
  bool get framesEnabled => super.framesEnabled && _readyToProduceFrames;
}
