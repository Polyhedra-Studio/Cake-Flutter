part of '../../cake_flutter.dart';

class TestElementWrapperCollection<W extends Widget>
    implements Iterable<TestElementWrapper<W>>, TestElementActions {
  final List<TestElementWrapper<W>> elements = [];
  String? collectionName;

  TestElementWrapperCollection({this.collectionName});

  void add(TestElementWrapper<W> element) {
    elements.add(element);
    element._parentCollectionName = collectionName;
  }

  W get widget {
    return elements.first.widget;
  }

  /// Taps on the first element in the collection.
  ///
  /// If the collection is empty, throws an exception. If this is intentional,
  /// turn off the [warnIfInvalid] flag.
  @override
  Future<void> tap({bool warnIfMissed = true, bool warnIfInvalid = true}) {
    if (elements.isEmpty) {
      return _throwMessage(
        'tap',
        thrownOn: '$collectionName.tap()',
        warnIfInvalid: warnIfInvalid,
      );
    }

    return elements.first
        .tap(warnIfMissed: warnIfMissed, warnIfInvalid: warnIfInvalid);
  }

  /// Enters text on the first element in the collection.
  ///
  /// If the collection is empty, throws an exception. If this is intentional,
  /// turn off the [warnIfInvalid] flag.
  @override
  Future<void> enterText(String text, {bool warnIfInvalid = true}) {
    if (elements.isEmpty) {
      _throwMessage(
        'enter text',
        thrownOn: '$collectionName.enterText()',
        warnIfInvalid: warnIfInvalid,
      );
    }
    return elements.first.enterText(text, warnIfInvalid: warnIfInvalid);
  }

  /// Focuses on the first element in the collection.
  ///
  /// If the collection is empty, throws an exception. If this is intentional,
  /// turn off the [warnIfInvalid] flag.
  @override
  Future<void> focus({bool warnIfInvalid = true}) {
    if (elements.isEmpty) {
      return _throwMessage(
        'focus',
        thrownOn: '$collectionName.focus()',
        warnIfInvalid: warnIfInvalid,
      );
    }
    return elements.first.focus(warnIfInvalid: warnIfInvalid);
  }

  /// Dismisses the first element in the collection.
  ///
  /// If the collection is empty, throws an exception. If this is intentional,
  /// turn off the [warnIfInvalid] flag.
  @override
  Future<void> dismiss({bool warnIfInvalid = true}) {
    if (elements.isEmpty) {
      return _throwMessage(
        'dismiss',
        thrownOn: '$collectionName.dismiss()',
        warnIfInvalid: warnIfInvalid,
      );
    }
    return elements.first.dismiss(warnIfInvalid: warnIfInvalid);
  }

  /// Swipes on the first element from one edge to the other.
  ///
  /// [SwipeDirection.Up] will start from the center bottom and go up.
  /// [SwipeDirection.Down] will start from the center top and go down.
  /// [SwipeDirection.Left] will start from the center right and go left.
  /// [SwipeDirection.Right] will start from the center left and go right.
  /// [duration] is the time taken to complete the swipe.
  ///
  /// For more control over swipe directions, use [swipeCustom].
  ///
  /// If the collection is empty, throws an exception. If this is intentional,
  /// turn off the [warnIfInvalid] flag.
  @override
  Future<void> swipe(
    SwipeDirection direction, {
    Duration duration = Duration.zero,
    bool warnIfInvalid = true,
  }) {
    if (elements.isEmpty) {
      return _throwMessage(
        'swipe',
        thrownOn: '$collectionName.swipe()',
        warnIfInvalid: warnIfInvalid,
      );
    }

    return elements.first
        .swipe(direction, duration: duration, warnIfInvalid: warnIfInvalid);
  }

  /// Swipes on the first element.
  ///
  /// [start] and [end] offsets are relative to the top left corner of the
  /// element.
  ///
  /// If the collection is empty, throws an exception. If this is intentional,
  /// turn off the [warnIfInvalid] flag.
  @override
  Future<void> swipeCustom({
    required Offset start,
    required Offset end,
    Duration duration = Duration.zero,
    bool warnIfInvalid = true,
  }) {
    if (elements.isEmpty) {
      return _throwMessage(
        'swipe',
        thrownOn: '$collectionName.swipeCustom()',
        warnIfInvalid: warnIfInvalid,
      );
    }

    return elements.first.swipeCustom(
      start: start,
      end: end,
      duration: duration,
      warnIfInvalid: warnIfInvalid,
    );
  }

  /// Takes a snapshot of all the elements in the collection, collated into a
  /// single column widget. If there is only one element in the collection, it
  /// the column will not be created.
  ///
  /// If the collection is empty, throws an exception. If this is intentional,
  /// turn off the [warnIfInvalid] flag.
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
    if (elements.isEmpty) {
      return _throwMessage<Snapshot>(
        'snapshot',
        thrownOn: '$collectionName.snapshot()',
        warnIfInvalid: warnIfInvalid,
      );
    }

    final Widget? snapshotWidget = elements.length == 1
        ? null
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: elements.map((element) => element.widget).toList(),
          );

    // The test element itself knows how to snapshot, so regardless if this is
    // one element or many, call the first one to take the snapshot.
    return elements.first.snapshot(
      includeSetupWidgets: includeSetupWidgets,
      createIfMissing: createIfMissing,
      createCopyIfMismatch: createCopyIfMismatch,
      mismatchDirectory: mismatchDirectory,
      mismatchFileName: mismatchFileName,
      overwriteGolden: overwriteGolden,
      directory: directory,
      fileName: fileName,
      fontFamily: fontFamily,
      snapshotWidget: snapshotWidget,
      snapshotWidgetSetup: snapshotWidgetSetup,
      warnIfInvalid: warnIfInvalid,
    );
  }

  /// Checks if the first element in the collection has the given type,
  /// subclasses included.
  ///
  /// Not to be confused with [hasType], which checks if one of the widgets
  /// in the collection has the given type.
  /// If the collection is empty, returns false. If this is intentional,
  /// turn off the [warnIfInvalid] flag.
  @override
  bool hasChildOfType<T extends Widget>() {
    if (elements.isEmpty) {
      return false;
    }
    return elements.first.hasChildOfType<T>();
  }

  /// Checks if any element in the collection is the given type,
  /// subclasses included.
  bool hasType<T extends Widget>() {
    if (elements.isEmpty) {
      return false;
    }
    return elements.any(
      (element) => element.widget is T,
    );
  }

  Future<T?> _throwMessage<T>(
    String action, {
    required String thrownOn,
    bool warnIfInvalid = true,
  }) async {
    if (warnIfInvalid) {
      throw CakeFlutterError.notFoundForAction(
        action,
        thrownOn: thrownOn,
      );
    }
    return null;
  }

  // ----- Iterable Overrides -----
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
    Iterable<TestElementWrapper<W>> other,
  ) {
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
