import 'package:cake/cake.dart';
import 'package:flutter_test/flutter_test.dart';

class FlutterExpect extends Expect {
  FlutterExpect({
    required super.actual,
    required super.expected,
  });

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

class _FlutterExpectMatcher extends FlutterExpect {
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
