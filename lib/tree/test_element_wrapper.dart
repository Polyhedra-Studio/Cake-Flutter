part of '../../cake_flutter.dart';

class TestElementWrapper<W extends Widget> implements TestElementActions {
  final bool isEmpty;
  final Element element;

  W? _widget;
  W get widget => _widget ?? (Container() as W);

  String? _parentCollectionName;

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
      throw CakeFlutterError.notInitialized();
    }
    return __tester!;
  }

  SnapshotWidgetCallback? __onSnapshot;
  SnapshotWidgetCallback get _onSnapshot {
    if (__onSnapshot == null) {
      throw CakeFlutterError.notInitialized(
        thrownOn: '$_parentCollectionName.snapshot()',
      );
    }
    return __onSnapshot!;
  }

  final TestElementWrapperCollection _children;
  TestElementWrapperCollection get children => _children;

  String get displayName => key != null
      ? '${widget.runtimeType} ${key.toString()}'
      : widget.runtimeType.toString();

  TestElementWrapper(
    this.element,
    this.__tester, {
    required SnapshotWidgetCallback onSnapshot,
    TestElementWrapperCollection? children,
  })  : __onSnapshot = onSnapshot,
        _children = children ?? TestElementWrapperCollection(),
        isEmpty = false {
    try {
      _widget = element.widget as W;
    } on TypeError catch (e) {
      if (e.toString() == 'Null check operator used on a null value') {
        throw CakeFlutterError(
          'Null check operator was used on a null value when fetching the widget.',
          hint:
              'This usually happens when the indexed Widget Tree is stale. Try calling index() again.',
          thrownOn: _parentCollectionName,
        );
      } else {
        rethrow;
      }
    }
    _parseElement();
  }

  TestElementWrapper.empty()
      : element = StatelessElement(Container()),
        _children = TestElementWrapperCollection<W>(),
        isEmpty = true;

  TestElementWrapper<W2> asType<W2 extends Widget>() {
    assert(widget is W2, 'Converting ${widget.runtimeType} to $W2');
    return TestElementWrapper<W2>(
      element,
      _tester,
      onSnapshot: _onSnapshot,
      children: _children,
    );
  }

  @override
  Future<void> tap({
    bool warnIfMissed = true,
    bool warnIfInvalid = true,
  }) async {
    if (isEmpty) {
      return _throwNotFoundMessage(
        'tap',
        warnIfInvalid: warnIfInvalid,
        thrownOn: 'tap()',
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
            return _throwMissedMessage(
              '$displayName at $location is outside the bounds of the root of the render tree, ${_tester.binding.renderView.size}.',
              warnIfInvalid: warnIfInvalid,
              thrownOn: 'tap()',
            );
          } else {
            return _throwMissedMessage(
              '$displayName at $location was not hit.',
              hint:
                  'The widget is could be off-screen, or another widget is obscuring it, or the widget cannot receive pointer events.',
              warnIfInvalid: warnIfInvalid,
              thrownOn: 'tap()',
            );
          }
        }
      }
      return TestAsyncUtils.guard(() => _tester.tapAt(location));
    } else {
      return _throwInvalidMessage(
        '$displayName does not have a render object to tap onto.',
        warnIfInvalid: warnIfInvalid,
        thrownOn: 'tap()',
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
      return _throwInvalidMessage(
        'Cannot focus on $displayName.',
        warnIfInvalid: warnIfInvalid,
        thrownOn: 'focus()',
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
      return _throwInvalidMessage(
        '$displayName is not a supported dismissible widget.',
        warnIfInvalid: warnIfInvalid,
        thrownOn: 'focus()',
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
  Future<Snapshot?> snapshot({
    bool? includeSetupWidgets,
    bool? createIfMissing,
    bool? createCopyIfMismatch,
    String? mismatchDirectory,
    String? mismatchFileName,
    bool? overwriteGolden,
    String? directory,
    String? fileName,
    String? fontFamily,
    Widget? snapshotWidget,
    SetupSettings? snapshotWidgetSetup,
    bool warnIfInvalid = true,
  }) {
    return _onSnapshot(
      includeSetupWidgets: includeSetupWidgets,
      createIfMissing: createIfMissing,
      createCopyIfMismatch: createCopyIfMismatch,
      mismatchDirectory: mismatchDirectory,
      mismatchFileName: mismatchFileName,
      overwriteGolden: overwriteGolden,
      directory: directory,
      fileName: fileName,
      fontFamily: fontFamily,
      snapshotWidget: snapshotWidget ?? widget,
      snapshotWidgetSetup: snapshotWidgetSetup,
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
      return _throwInvalidMessage(
        '$displayName does not have a valid render object to swipe.',
        warnIfInvalid: warnIfInvalid,
        thrownOn: 'swipe()',
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

  void _throwInvalidMessage(
    String message, {
    bool warnIfInvalid = true,
    required String thrownOn,
  }) {
    if (warnIfInvalid) {
      throw CakeFlutterError.invalidForAction(
        message,
        thrownOn: '$_parentCollectionName.$thrownOn',
      );
    }
    return;
  }

  void _throwMissedMessage(
    String message, {
    required bool warnIfInvalid,
    required String thrownOn,
    String? hint,
  }) {
    if (warnIfInvalid) {
      throw CakeFlutterError.missedForAction(
        message,
        thrownOn: '$_parentCollectionName.$thrownOn',
        hints: hint != null ? [hint] : null,
      );
    }
    return;
  }

  void _throwNotFoundMessage(
    String action, {
    required bool warnIfInvalid,
    required String thrownOn,
  }) {
    if (warnIfInvalid) {
      throw CakeFlutterError.notFoundForAction(
        action,
        thrownOn: '$_parentCollectionName.$thrownOn',
      );
    }
    return;
  }
}
