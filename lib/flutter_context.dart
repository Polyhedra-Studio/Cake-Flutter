import 'dart:async';

import 'package:cake_flutter/cake_flutter.dart';
import 'package:cake_flutter/flutter_test_options.dart';
import 'package:cake_flutter/search.dart';
import 'package:cake_flutter/widget_tree.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class FlutterContext extends Context {
  final FlutterTestOptions? options;
  Search? _search;
  WidgetTester? _bootstrapTester;

  /// Returns the [Search] instance.
  ///
  /// Throws an exception if [index] has not been called before accessing [search].
  Search get search {
    if (_search == null) {
      throw 'In order to utilize search, please call index() first.';
    }

    return _search!;
  }

  bool get searchInitialized {
    return _search != null;
  }

  /// Returns the Flutter [WidgetTester] instance.
  /// While for most use cases there are helper functions, it's here
  /// if you want to access it directly or to quickly convert existing tests.
  ///
  /// Synonym for [bootstrapTester]
  WidgetTester get tester => bootstrapTester;

  WidgetTester get bootstrapTester {
    if (_bootstrapTester == null) {
      throw 'App not initialized or is not ready yet. Call setApp() in an async first.';
    }
    return _bootstrapTester!;
  }

  // Bootstrap tester is provided once this is copied from the parent
  // OnComplete should only be called once from the TestRunner
  FlutterContext._child({required this.options});

  FlutterContext._({
    required this.options,
    required WidgetTester tester,
  }) : _bootstrapTester = tester;

  @override
  void copyExtraParams(Context contextToCopyFrom) {
    if (contextToCopyFrom is FlutterContext) {
      _bootstrapTester = contextToCopyFrom._bootstrapTester;
      _search = contextToCopyFrom._search;
    }
  }

  Future<void> setApp(Widget app) async {
    return bootstrapTester.pumpWidget(app);
  }

  void index() {
    if (bootstrapTester.binding.rootElement == null) {
      throw 'App not initialized or is not ready yet. Call setApp() in an async first.';
    }
    final WidgetTree tree = WidgetTree(bootstrapTester.binding.rootElement!);
    tree.index(bootstrapTester);
    _search = Search(tree);
  }

  Future<void> forward({Duration? duration}) async {
    await bootstrapTester.pump(duration);
  }
}

class FlutterContextController {
  static final FlutterContextController _instance =
      FlutterContextController._();
  factory FlutterContextController() => _instance;
  FlutterContextController._();

  static bool _parentContextHasInitialized = false;
  static Completer<void>? _onComplete;
  static Completer<void>? get onComplete {
    return _onComplete;
  }

  static FutureOr<FlutterContext> flutterContextBuilder({
    required FlutterTestOptions? options,
    required String title,
  }) {
    if (!_parentContextHasInitialized) {
      _parentContextHasInitialized = true;
      final Completer<FlutterContext> completer = Completer<FlutterContext>();
      testWidgets(
        title,
        (widgetTester) async {
          final Completer<void> cakeTestsComplete = Completer<void>();

          _onComplete = cakeTestsComplete;
          completer.complete(
            FlutterContext._(options: options, tester: widgetTester),
          );

          // Signal to Flutter tester that Cake has completed its tests and
          // Flutter tester may now begin teardown.
          await cakeTestsComplete.future;
        },
      );
      return completer.future;
    } else {
      return FlutterContext._child(options: options);
    }
  }
}
