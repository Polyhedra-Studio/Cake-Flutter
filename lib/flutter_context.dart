part of '../cake_flutter.dart';

class FlutterContext extends Context {
  final FlutterTestOptions? options;
  Search? _search;
  WidgetTester? _bootstrapTester;

  /// Returns the [Search] instance.
  ///
  /// Will setup an index with no filters if not set yet.
  Search get search {
    if (_search == null) {
      _index(IndexOptions());
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

  /// Set the entrypoint to test in. Extra arguments are included for common
  /// widget wrappers, such as [Directionality], [Theme], [Scaffold], and [MaterialApp].
  ///
  /// If [textDirection] is provided, the widget will be wrapped in a
  /// [Directionality] widget.
  /// If [themeData] is provided, the widget will be wrapped in a
  /// [Theme] widget or included in MaterialApp if added.
  /// If [locale] is provided, the widget will be wrapped in a
  /// [Localizations] widget with default delegates (unless specified).
  /// If [includeScaffold] is turned on, the widget will be wrapped in a simple
  /// [Scaffold] widget and [MaterialApp]. (CupertinoApp if [includeCupertinoApp]
  /// is turned on)
  /// If [includeMaterialApp] is turned on, the widget will be wrapped in a
  /// [MaterialApp] widget, with the widget set as [MaterialApp.home].
  Future<void> setApp(
    Widget root, {
    TextDirection? textDirection,
    ThemeData? theme,
    Locale? locale,
    List<LocalizationsDelegate>? delegates,
    bool includeScaffold = false,
    bool includeMaterialApp = false,
  }) async {
    Widget app = root;

    // Set delegates if locale is used and vice-versa
    if (locale != null && delegates == null) {
      delegates = <LocalizationsDelegate>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];
    } else if (locale == null && delegates != null) {
      locale = const Locale('en', 'US');
    }

    // RTL is not the default, so this should be set regardless of other flags.
    if (textDirection == TextDirection.rtl) {
      app = Directionality(textDirection: TextDirection.rtl, child: app);
    }

    // LTR is the default, so Material and Cupertino already do this.
    if (textDirection == TextDirection.ltr && !includeMaterialApp) {
      app = Directionality(textDirection: TextDirection.ltr, child: app);
    }

    if (theme != null && !includeMaterialApp) {
      app = Theme(data: theme, child: app);
    }

    if ((locale != null && delegates != null) && !includeMaterialApp) {
      app = Localizations(
        locale: locale,
        delegates: delegates,
        child: app,
      );
    }

    if (includeScaffold) {
      app = Scaffold(body: app);

      if (!includeMaterialApp) {
        // Scaffold needs a root App base in order to work
        app = MaterialApp(
          home: app,
          theme: theme,
          locale: locale,
          localizationsDelegates: delegates,
        );
      }
    }

    // Base Material or Cupertino app
    if (includeMaterialApp) {
      app = MaterialApp(
        home: app,
        theme: theme,
        locale: locale,
        localizationsDelegates: delegates,
      );
    }

    return TestAsyncUtils.guard(() => bootstrapTester.pumpWidget(app));
  }

  void index([IndexOptions? options]) {
    if (bootstrapTester.binding.rootElement == null) {
      throw 'App not initialized or is not ready yet. Call setApp() in an async first.';
    }
    options ??= IndexOptions();
    _index(options);
  }

  void _index(IndexOptions options) {
    final WidgetTree tree = WidgetTree(
      bootstrapTester.binding.rootElement!,
      indexOptions: options,
    );
    tree.index(options, bootstrapTester);
    _search = Search(tree);
  }

  Future<void> forward({Duration? duration}) {
    return TestAsyncUtils.guard(() => bootstrapTester.pump(duration));
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
          widgetTester.runAsync(() async {
            final Completer<void> cakeTestsComplete = Completer<void>();

            _onComplete = cakeTestsComplete;
            completer.complete(
              FlutterContext._(options: options, tester: widgetTester),
            );

            // Signal to Flutter tester that Cake has completed its tests and
            // Flutter tester may now begin teardown.
            await cakeTestsComplete.future;

            TestAsyncUtils.verifyAllScopesClosed();
          });
        },
      );
      return completer.future;
    } else {
      return FlutterContext._child(options: options);
    }
  }
}
