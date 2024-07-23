part of '../cake_flutter.dart';

class TestElementWrapper<W extends Widget> implements TestElementActions {
  final bool isEmpty;
  final Element element;

  W widget;

  Key? _key;
  Key? get key => _key;

  String? _keyText;
  String? get keyText => _keyText;

  String? _text;
  String? get text => _text;

  IconData? _iconData;
  IconData? get iconData => _iconData;

  bool _isDismissible = false;
  bool get isDismissible => _isDismissible;

  WidgetTester? __tester;
  WidgetTester get _tester {
    if (__tester == null) {
      throw 'Element is not ready yet. Call setApp() in an async first.';
    }
    return __tester!;
  }

  final TestElementWrapperCollection _children;
  TestElementWrapperCollection get children => _children;

  String get displayName => key != null
      ? '${widget.runtimeType} ${key.toString()}'
      : widget.runtimeType.toString();

  TestElementWrapper(
    this.element,
    this.__tester, {
    TestElementWrapperCollection? children,
  })  : widget = (element.widget as W),
        _children = children ?? TestElementWrapperCollection(),
        isEmpty = false {
    _parseElement();
  }

  TestElementWrapper.empty()
      : widget = Container() as W,
        element = StatelessElement(Container()),
        _children = TestElementWrapperCollection<W>(),
        isEmpty = true;

  TestElementWrapper<W2> asType<W2 extends Widget>() {
    assert(widget is W2, 'Converting ${widget.runtimeType} to $W2');
    return TestElementWrapper<W2>(element, _tester, children: _children);
  }

  @override
  Future<void> tap({
    bool warnIfMissed = true,
    bool warnIfInvalid = true,
  }) async {
    if (isEmpty) {
      return _throwMessage(
        'Cannot tap on a widget that does not exist.',
        warnIfInvalid: warnIfInvalid,
      );
    }

    final Offset? location = _fetchPosition(Alignment.center);

    if (location != null) {
      // Check if this is in the hit box and warn if so
      if (warnIfMissed) {
        final HitTestResult result = HitTestResult();
        _tester.binding.hitTest(result, location);
        bool found = false;
        // _fetchPosition checks against the box, so this is a safe assumption
        final RenderObject box = element.renderObject!;
        for (final HitTestEntry entry in result.path) {
          if (entry.target == box) {
            found = true;
            break;
          }
        }

        if (!found) {
          final bool outOfBounds =
              !(Offset.zero & _tester.binding.renderView.size)
                  .contains(location);
          if (outOfBounds) {
            return _throwMessage(
              '$displayName at $location is outside the bounds of the root of the render tree, ${_tester.binding.renderView.size}.',
              warnIfInvalid: warnIfInvalid,
            );
          } else {
            return _throwMessage(
              '''
$displayName at $location was not hit. Maybe the widget is actually off-screen, or another widget is obscuring it, or the widget cannot receive pointer events.
''',
              warnIfInvalid: warnIfInvalid,
            );
          }
        }
      }
      return TestAsyncUtils.guard(() => _tester.tapAt(location));
    } else {
      return _throwMessage(
        '$displayName does not have a render object to tap onto.',
        warnIfInvalid: warnIfInvalid,
      );
    }
  }

  @override
  Future<void> focus({bool warnIfInvalid = true}) async {
    // Find text field, if any
    final TestElementWrapper<EditableText>? focusElement =
        _getChildOfWidgetType<EditableText>();

    if (focusElement == null ||
        focusElement.element is! StatefulElement ||
        (focusElement.element as StatefulElement).state is! EditableTextState) {
      return _throwMessage(
        'Cannot focus on $displayName.',
        warnIfInvalid: warnIfInvalid,
      );
    }

    return TestAsyncUtils.guard(() async {
      _tester.binding.focusedEditable =
          (focusElement.element as StatefulElement).state as EditableTextState;
      await _tester.pump();
    });
  }

  @override
  Future<void> enterText(String text, {bool warnIfInvalid = true}) async {
    return TestAsyncUtils.guard(() async {
      await focus();
      _tester.binding.testTextInput.enterText(text);
      await _tester.binding.idle();
    });
  }

  @override
  Future<void> dismiss({bool warnIfInvalid = true}) async {
    if (!_isDismissible) {
      return _throwMessage(
        '$displayName is not a supported dismissible widget.',
        warnIfInvalid: warnIfInvalid,
      );
    }

    return swipe(SwipeDirection.down, warnIfInvalid: warnIfInvalid);
  }

  /// Swipe from one edge to the other.
  ///
  /// [SwipeDirection.Up] will start from the bottom and go up.
  /// [SwipeDirection.Down] will start from the top and go down.
  /// [SwipeDirection.Left] will start from the right and go left.
  /// [SwipeDirection.Right] will start from the left and go right.
  /// [duration] is the time taken to complete the swipe.
  @override
  Future<void> swipe(
    SwipeDirection direction, {
    Duration duration = Duration.zero,
    bool warnIfInvalid = true,
  }) async {
    Alignment start;
    Alignment end;
    switch (direction) {
      case SwipeDirection.up:
        start = Alignment.topCenter;
        end = Alignment.bottomCenter;
        break;
      case SwipeDirection.down:
        start = Alignment.bottomCenter;
        end = Alignment.topCenter;
        break;
      case SwipeDirection.left:
        start = Alignment.centerRight;
        end = Alignment.centerLeft;
        break;
      case SwipeDirection.right:
        start = Alignment.centerLeft;
        end = Alignment.centerRight;
        break;
    }
    final Offset? startSwipeDownLocation = _fetchPosition(start);
    final Offset? endSwipeDownLocation = _fetchPosition(end);

    return _swipe(
      start: startSwipeDownLocation,
      end: endSwipeDownLocation,
      duration: duration,
      warnIfInvalid: warnIfInvalid,
    );
  }

  @override
  Future<void> swipeCustom({
    required Offset start,
    required Offset end,
    Duration duration = Duration.zero,
    bool warnIfInvalid = true,
  }) {
    final Offset? startSwipeDownLocation = _fetchPositionFromOffset(start);
    final Offset? endSwipeDownLocation = _fetchPositionFromOffset(end);

    return _swipe(
      start: startSwipeDownLocation,
      end: endSwipeDownLocation,
      duration: duration,
      warnIfInvalid: warnIfInvalid,
    );
  }

  @override
  bool hasChildOfType<T extends Widget>() {
    bool found = false;

    element.visitChildren(
      (element) {
        if (element.widget is T) {
          found = true;
        }
      },
    );

    return found;
  }

  void _addChild(TestElementWrapper child) {
    _children.add(child);
  }

  void _parseElement() {
    if (element.widget.key != null) {
      _key = element.widget.key;

      if (element.widget.key is ValueKey<String>) {
        _keyText = (element.widget.key as ValueKey<String>).value;
      }
    }

    if (widget is Text) {
      _text = (widget as Text).data;
    }

    if (widget is Icon) {
      _iconData = (widget as Icon).icon;
    }

    if (widget is SnackBar) {
      _isDismissible = true;
    }
  }

  TestElementWrapper<W2>? _getChildOfWidgetType<W2 extends Widget>() {
    if (widget is W2) {
      return this.asType<W2>();
    }

    for (var child in children) {
      final TestElementWrapper<W2>? found = child._getChildOfWidgetType<W2>();
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  Future<void> _swipe({
    required Offset? start,
    required Offset? end,
    Duration duration = Duration.zero,
    bool warnIfInvalid = true,
  }) async {
    if (start == null || end == null) {
      return _throwMessage(
        '$displayName does not have a valid render object to swipe.',
        warnIfInvalid: warnIfInvalid,
      );
    }

    return TestAsyncUtils.guard(() async {
      final TestGesture gesture = await _tester.startGesture(start);
      await gesture.moveTo(end, timeStamp: duration);
      await gesture.up();
    });
  }

  Offset? _fetchPosition(Alignment location) {
    final RenderObject? box = element.renderObject;
    if (box is RenderBox) {
      return box.localToGlobal(location.alongSize(box.size));
    }
    return null;
  }

  Offset? _fetchPositionFromOffset(Offset offset) {
    final RenderObject? box = element.renderObject;
    if (box is RenderBox) {
      return box.globalToLocal(offset);
    }
    return null;
  }

  void _throwMessage(String message, {bool warnIfInvalid = true}) {
    if (warnIfInvalid) {
      const String mutedMessage =
          '\nIf this action is intentional, mute this message from the "warnIfMissed" flag.';
      throw '$message$mutedMessage';
    }
    return;
  }
}
