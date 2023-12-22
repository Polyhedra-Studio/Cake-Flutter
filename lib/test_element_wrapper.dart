import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TestElementWrapper<W extends Widget> {
  final Element element;
  W widget;

  String? _text;
  String? get text => _text;

  IconData? _iconData;
  IconData? get iconData => _iconData;

  TestElementWrapper(this.element) : widget = (element.widget as W) {
    _parseElement();
  }

  TestElementWrapper.empty()
      : widget = Container() as W,
        element = StatelessElement(Container());

  TestElementWrapper<W2> asType<W2 extends Widget>() {
    assert(widget is W2, 'Converting ${widget.runtimeType} to $W2');
    return TestElementWrapper<W2>(element);
  }

  void tap() {
    // Find position to tap
    final RenderObject? object = element.renderObject;

    // Find center of object
    if (object is RenderBox) {
      // Find center of object
      final Offset center = object.size.center(Offset.zero);
      final hitTestResult = BoxHitTestResult();
      if (object.hitTest(hitTestResult, position: center)) {
        // a descendant of `renderObj` got tapped
        print(hitTestResult.path);
      }
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
