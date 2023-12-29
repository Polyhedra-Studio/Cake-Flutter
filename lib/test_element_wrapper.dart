part of '../cake_flutter.dart';

class TestElementWrapper<W extends Widget> {
  final Element element;

  W widget;

  Key? _key;
  Key? get key => _key;

  String? _text;
  String? get text => _text;

  IconData? _iconData;
  IconData? get iconData => _iconData;

  WidgetTester? __tester;
  WidgetTester get _tester {
    if (__tester == null) {
      throw 'Element is not ready yet. Call setApp() in an async first.';
    }
    return __tester!;
  }

  final TestElementWrapperCollection _children;
  TestElementWrapperCollection get children => _children;

  TestElementWrapper(this.element, this.__tester,
      {TestElementWrapperCollection? children})
      : widget = (element.widget as W),
        _children = children ?? TestElementWrapperCollection() {
    _parseElement();
  }

  TestElementWrapper.empty()
      : widget = Container() as W,
        element = StatelessElement(Container()),
        _children = TestElementWrapperCollection<W>();

  TestElementWrapper<W2> asType<W2 extends Widget>() {
    assert(widget is W2, 'Converting ${widget.runtimeType} to $W2');
    return TestElementWrapper<W2>(element, _tester, children: _children);
  }

  Future<void> tap({bool warnIfMissed = true}) {
    // Find position to tap
    final RenderObject? box = element.renderObject;

    // Find center of object
    if (box is RenderBox) {
      // Find center of object
      final Offset location = box.localToGlobal(box.size.center(Offset.zero));

      // Check if this is in the hit box and warn if so
      if (warnIfMissed) {
        final HitTestResult result = HitTestResult();
        _tester.binding.hitTest(result, location);
        bool found = false;
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
            throw '${widget.runtimeType} at $location is outside the bounds of the root of the render tree, ${_tester.binding.renderView.size}.';
          } else {
            throw '${widget.runtimeType} at $location was not hit.';
          }
        }
      }
      return TestAsyncUtils.guard(() => _tester.tapAt(location));
    } else {
      throw 'Element does not have a render object to tap onto.';
    }
  }

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
    }

    if (element is StatelessElement) {
      if (widget is Text) {
        _text = (widget as Text).data;
      }

      if (widget is Icon) {
        _iconData = (widget as Icon).icon;
      }
    }
  }
}
