part of '../cake_flutter.dart';

class FlutterExpect<ExpectedType extends Widget> extends Expect<ExpectedType> {
  FlutterExpect({
    required super.actual,
    required super.expected,
  });

  factory FlutterExpect.isWidgetType(TestElementWrapper wrapper) {
    return _FlutterExpectIsWidgetType<ExpectedType>(wrapper);
  }

  // --- Search Matches ---
  factory FlutterExpect.searchHasNone(
    TestElementWrapperCollection searchResults,
  ) {
    return _FlutterExpectSearchIsEmpty(searchResults: searchResults);
  }

  factory FlutterExpect.searchHasOne(
    TestElementWrapperCollection searchResults,
  ) {
    return _FlutterExpectSearchHasOne(searchResults: searchResults);
  }

  factory FlutterExpect.searchHasSome(
    TestElementWrapperCollection searchResults,
  ) {
    return _FlutterExpectSearchHasSome(searchResults: searchResults);
  }

  factory FlutterExpect.searchHasN(
    TestElementWrapperCollection searchResults, {
    required int n,
  }) {
    return _FlutterExpectSearchHasN(searchResults: searchResults, n: n);
  }

  // --- Finder Matches ---
  factory FlutterExpect.findMatch({
    required Finder find,
    required Matcher match,
  }) {
    return _FlutterExpectMatcher(
      finder: find,
      matcher: match,
    );
  }

  factory FlutterExpect.findsOneWidget(Finder find) {
    return _FlutterExpectMatcher(
      finder: find,
      matcher: findsOneWidget,
    );
  }

  factory FlutterExpect.findsNothing(Finder find) {
    return _FlutterExpectMatcher(
      finder: find,
      matcher: findsNothing,
    );
  }

  factory FlutterExpect.findsWidgets(Finder find) {
    return _FlutterExpectMatcher(
      finder: find,
      matcher: findsWidgets,
    );
  }

  factory FlutterExpect.findsNWidgets(Finder find, {required int n}) {
    return _FlutterExpectMatcher(
      finder: find,
      matcher: findsNWidgets(n),
      count: n,
    );
  }

  factory FlutterExpect.findsAtLeastNWidgets(Finder find, {required int n}) {
    return _FlutterExpectMatcher(
      finder: find,
      matcher: findsAtLeastNWidgets(n),
      count: n,
    );
  }
}

class _FlutterExpectIsWidgetType<ExpectedType extends Widget>
    extends FlutterExpect<ExpectedType> {
  final TestElementWrapper _wrapper;

  _FlutterExpectIsWidgetType(this._wrapper)
      : super(actual: null, expected: null);

  @override
  AssertResult run() {
    if (_wrapper.widget is ExpectedType) {
      return AssertPass();
    } else {
      return AssertFailure(
        'IsWidgetType failed: Expected $ExpectedType, got ${_wrapper.widget.runtimeType}.',
      );
    }
  }
}

class _FlutterExpectSearchIsEmpty<ExpectedType extends Widget>
    extends FlutterExpect<ExpectedType> {
  final TestElementWrapperCollection searchResults;

  _FlutterExpectSearchIsEmpty({required this.searchResults})
      : super(actual: null, expected: null);

  @override
  AssertResult run() {
    if (searchResults.isEmpty) {
      return AssertPass();
    } else {
      return AssertFailure(
        'HasNone failed: Found ${searchResults.length} widgets.',
      );
    }
  }
}

class _FlutterExpectSearchHasOne<ExpectedType extends Widget>
    extends FlutterExpect<ExpectedType> {
  final TestElementWrapperCollection searchResults;

  _FlutterExpectSearchHasOne({required this.searchResults})
      : super(actual: null, expected: null);

  @override
  AssertResult run() {
    if (searchResults.length == 1) {
      return AssertPass();
    } else {
      return AssertFailure(
        'HasOne failed: Found ${searchResults.length} widgets.',
      );
    }
  }
}

class _FlutterExpectSearchHasSome<ExpectedType extends Widget>
    extends FlutterExpect<ExpectedType> {
  final TestElementWrapperCollection searchResults;

  _FlutterExpectSearchHasSome({required this.searchResults})
      : super(actual: null, expected: null);

  @override
  AssertResult run() {
    if (searchResults.isNotEmpty) {
      return AssertPass();
    } else {
      return AssertFailure(
        'HasSome failed: Found no widgets.',
      );
    }
  }
}

class _FlutterExpectSearchHasN<ExpectedType extends Widget>
    extends FlutterExpect<ExpectedType> {
  final TestElementWrapperCollection searchResults;
  final int n;

  _FlutterExpectSearchHasN({required this.searchResults, required this.n})
      : super(actual: null, expected: null);

  @override
  AssertResult run() {
    if (searchResults.length == n) {
      return AssertPass();
    } else {
      return AssertFailure(
        'HasN failed: Found ${searchResults.length} widgets, expected $n.',
      );
    }
  }
}

class _FlutterExpectMatcher<ExpectedType extends Widget>
    extends FlutterExpect<ExpectedType> {
  final Finder finder;
  final Matcher matcher;
  final int? count;

  _FlutterExpectMatcher({
    required this.finder,
    required this.matcher,
    this.count,
  }) : super(actual: null, expected: null);

  @override
  AssertResult run() {
    if (matcher.matches(finder, {})) {
      return AssertPass();
    } else {
      String expectedMatcher = '';
      if (matcher == findsOneWidget) {
        expectedMatcher = 'one widget';
      } else if (matcher == findsNothing) {
        expectedMatcher = 'nothing';
      } else if (matcher == findsWidgets) {
        expectedMatcher = 'at least some widgets';
      } else if (matcher == findsNWidgets(count ?? 0)) {
        expectedMatcher = '${count ?? 'unknown count'} widgets';
      }

      String foundResult = '';
      final int foundCount = finder.evaluate().length;
      if (foundCount == 0) {
        foundResult = 'none';
      } else if (foundCount == 1) {
        foundResult = 'one widget';
      } else {
        foundResult = '$foundCount widgets';
      }
      return AssertFailure(
        'Find failed: Expected to find $expectedMatcher, but found $foundResult.',
      );
    }
  }
}
