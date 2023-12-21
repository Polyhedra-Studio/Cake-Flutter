import 'package:flutter/widgets.dart';

class TestElementWrapper {
  final Element element;
  Widget widget;

  String? _text;
  String? get text => _text;
  TestElementWrapper(this.element) : widget = element.widget {
    _parseElement();
  }

  TestElementWrapper.empty()
      : widget = Container(),
        element = StatelessElement(Container());

  void _parseElement() {
    if (element is StatelessElement) {
      if (widget is Text) {
        _text = (widget as Text).data;
      }
    }
  }

  void tap() {
    // TODO
  }
}

class TestElementWrapperCollection implements Iterable<TestElementWrapper> {
  final List<TestElementWrapper> elements = [];

  TestElementWrapperCollection();

  void add(TestElementWrapper element) {
    elements.add(element);
  }

  @override
  TestElementWrapper get first {
    if (elements.isNotEmpty) {
      return elements.first;
    } else {
      return TestElementWrapper.empty();
    }
  }

  @override
  TestElementWrapper get last {
    if (elements.isNotEmpty) {
      return elements.last;
    } else {
      return TestElementWrapper.empty();
    }
  }

  @override
  TestElementWrapper elementAt(int index) {
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
  bool every(bool Function(TestElementWrapper element) test) {
    return elements.every(test);
  }

  @override
  Iterable<T> expand<T>(
    Iterable<T> Function(TestElementWrapper element) toElements,
  ) {
    return elements.expand<T>(toElements);
  }

  @override
  TestElementWrapper firstWhere(
    bool Function(TestElementWrapper element) test, {
    TestElementWrapper Function()? orElse,
  }) {
    return elements.firstWhere(
      test,
      orElse: orElse ?? () => TestElementWrapper.empty(),
    );
  }

  @override
  T fold<T>(
    T initialValue,
    T Function(T previousValue, TestElementWrapper element) combine,
  ) {
    return elements.fold<T>(initialValue, combine);
  }

  @override
  Iterable<TestElementWrapper> followedBy(Iterable<TestElementWrapper> other) {
    return elements.followedBy(other);
  }

  @override
  void forEach(void Function(TestElementWrapper element) action) {
    elements.forEach(action);
  }

  @override
  bool get isEmpty => elements.isEmpty;

  @override
  bool get isNotEmpty => elements.isNotEmpty;

  @override
  Iterator<TestElementWrapper> get iterator => elements.iterator;

  @override
  String join([String separator = ""]) {
    return elements.join(separator);
  }

  @override
  TestElementWrapper lastWhere(
    bool Function(TestElementWrapper element) test, {
    TestElementWrapper Function()? orElse,
  }) {
    return elements.lastWhere(
      test,
      orElse: orElse ?? () => TestElementWrapper.empty(),
    );
  }

  @override
  int get length => elements.length;

  @override
  Iterable<T> map<T>(T Function(TestElementWrapper e) toElement) {
    return elements.map<T>(toElement);
  }

  @override
  TestElementWrapper reduce(
    TestElementWrapper Function(
      TestElementWrapper value,
      TestElementWrapper element,
    ) combine,
  ) {
    return elements.reduce(combine);
  }

  @override
  TestElementWrapper get single {
    if (elements.length == 1) {
      return elements.single;
    } else {
      return TestElementWrapper.empty();
    }
  }

  @override
  TestElementWrapper singleWhere(
    bool Function(TestElementWrapper element) test, {
    TestElementWrapper Function()? orElse,
  }) {
    return elements.singleWhere(
      test,
      orElse: orElse ?? () => TestElementWrapper.empty(),
    );
  }

  @override
  Iterable<TestElementWrapper> skip(int count) {
    return elements.skip(count);
  }

  @override
  Iterable<TestElementWrapper> skipWhile(
    bool Function(TestElementWrapper value) test,
  ) {
    return elements.skipWhile(test);
  }

  @override
  Iterable<TestElementWrapper> take(int count) {
    return elements.take(count);
  }

  @override
  Iterable<TestElementWrapper> takeWhile(
    bool Function(TestElementWrapper value) test,
  ) {
    return elements.takeWhile(test);
  }

  @override
  List<TestElementWrapper> toList({bool growable = true}) {
    return elements.toList(growable: growable);
  }

  @override
  Set<TestElementWrapper> toSet() {
    return elements.toSet();
  }

  @override
  Iterable<TestElementWrapper> where(
    bool Function(TestElementWrapper element) test,
  ) {
    return elements.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return elements.whereType<T>();
  }

  @override
  bool any(bool Function(TestElementWrapper element) test) {
    return elements.any(test);
  }
}
