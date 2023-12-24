import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TestElementWrapper<W extends Widget> {
  final Element element;
  W widget;

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

  TestElementWrapper(this.element, this.__tester)
      : widget = (element.widget as W) {
    _parseElement();
  }

  TestElementWrapper.empty()
      : widget = Container() as W,
        element = StatelessElement(Container());

  TestElementWrapper<W2> asType<W2 extends Widget>() {
    assert(widget is W2, 'Converting ${widget.runtimeType} to $W2');
    return TestElementWrapper<W2>(element, _tester);
  }

  Future<void> tap({bool warnIfMissed = true}) async {
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
      await _tester.tapAt(location);
    } else {
      throw 'Element does not have a render object to tap onto.';
    }
  }

  void _parseElement() {
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

class TestElementWrapperCollection<W extends Widget>
    implements Iterable<TestElementWrapper<W>> {
  final List<TestElementWrapper<W>> elements = [];

  TestElementWrapperCollection();

  void add(TestElementWrapper<W> element) {
    elements.add(element);
  }

  @override
  TestElementWrapper<W> get first {
    if (elements.isNotEmpty) {
      return elements.first;
    } else {
      return TestElementWrapper.empty();
    }
  }

  @override
  TestElementWrapper<W> get last {
    if (elements.isNotEmpty) {
      return elements.last;
    } else {
      return TestElementWrapper.empty();
    }
  }

  @override
  TestElementWrapper<W> elementAt(int index) {
    if (elements.length > index) {
      return elements.elementAt(index);
    } else {
      return TestElementWrapper.empty();
    }
  }

  @override
  Iterable<R> cast<R>() {
    return elements.cast<R>();
  }

  @override
  bool contains(Object? element) {
    return elements.contains(element);
  }

  @override
  bool every(bool Function(TestElementWrapper<W> element) test) {
    return elements.every(test);
  }

  @override
  Iterable<T> expand<T>(
    Iterable<T> Function(TestElementWrapper<W> element) toElements,
  ) {
    return elements.expand<T>(toElements);
  }

  @override
  TestElementWrapper<W> firstWhere(
    bool Function(TestElementWrapper<W> element) test, {
    TestElementWrapper<W> Function()? orElse,
  }) {
    return elements.firstWhere(
      test,
      orElse: orElse ?? () => TestElementWrapper.empty(),
    );
  }

  @override
  T fold<T>(
    T initialValue,
    T Function(T previousValue, TestElementWrapper<W> element) combine,
  ) {
    return elements.fold<T>(initialValue, combine);
  }

  @override
  Iterable<TestElementWrapper<W>> followedBy(
      Iterable<TestElementWrapper<W>> other) {
    return elements.followedBy(other);
  }

  @override
  void forEach(void Function(TestElementWrapper<W> element) action) {
    elements.forEach(action);
  }

  @override
  bool get isEmpty => elements.isEmpty;

  @override
  bool get isNotEmpty => elements.isNotEmpty;

  @override
  Iterator<TestElementWrapper<W>> get iterator => elements.iterator;

  @override
  String join([String separator = ""]) {
    return elements.join(separator);
  }

  @override
  TestElementWrapper<W> lastWhere(
    bool Function(TestElementWrapper<W> element) test, {
    TestElementWrapper<W> Function()? orElse,
  }) {
    return elements.lastWhere(
      test,
      orElse: orElse ?? () => TestElementWrapper.empty(),
    );
  }

  @override
  int get length => elements.length;

  @override
  Iterable<T> map<T>(T Function(TestElementWrapper<W> e) toElement) {
    return elements.map<T>(toElement);
  }

  @override
  TestElementWrapper<W> reduce(
    TestElementWrapper<W> Function(
      TestElementWrapper<W> value,
      TestElementWrapper<W> element,
    ) combine,
  ) {
    return elements.reduce(combine);
  }

  @override
  TestElementWrapper<W> get single {
    if (elements.length == 1) {
      return elements.single;
    } else {
      return TestElementWrapper.empty();
    }
  }

  @override
  TestElementWrapper<W> singleWhere(
    bool Function(TestElementWrapper<W> element) test, {
    TestElementWrapper<W> Function()? orElse,
  }) {
    return elements.singleWhere(
      test,
      orElse: orElse ?? () => TestElementWrapper.empty(),
    );
  }

  @override
  Iterable<TestElementWrapper<W>> skip(int count) {
    return elements.skip(count);
  }

  @override
  Iterable<TestElementWrapper<W>> skipWhile(
    bool Function(TestElementWrapper<W> value) test,
  ) {
    return elements.skipWhile(test);
  }

  @override
  Iterable<TestElementWrapper<W>> take(int count) {
    return elements.take(count);
  }

  @override
  Iterable<TestElementWrapper<W>> takeWhile(
    bool Function(TestElementWrapper<W> value) test,
  ) {
    return elements.takeWhile(test);
  }

  @override
  List<TestElementWrapper<W>> toList({bool growable = true}) {
    return elements.toList(growable: growable);
  }

  @override
  Set<TestElementWrapper<W>> toSet() {
    return elements.toSet();
  }

  @override
  Iterable<TestElementWrapper<W>> where(
    bool Function(TestElementWrapper<W> element) test,
  ) {
    return elements.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return elements.whereType<T>();
  }

  @override
  bool any(bool Function(TestElementWrapper<W> element) test) {
    return elements.any(test);
  }
}
