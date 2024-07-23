part of '../cake_flutter.dart';

class FlutterContext extends Context {
  final FlutterTestOptions? options;
  Search? _search;
  WidgetTester? _bootstrapTester;
  RootWidget? _root;
  String? _rootKey;

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
  })  : _bootstrapTester = tester,
        _root = RootWidget();

  @override
  void copyExtraParams(Context contextToCopyFrom) {
    if (contextToCopyFrom is FlutterContext) {
      _bootstrapTester = contextToCopyFrom._bootstrapTester;
      _search = contextToCopyFrom._search;
      _root = contextToCopyFrom._root;
      _rootKey = contextToCopyFrom._rootKey;
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
  ///
  ///
  Future<void> setApp(
    Widget root, {
    TextDirection? textDirection,
    ThemeData? theme,
    Locale? locale,
    List<LocalizationsDelegate>? delegates,
    bool includeScaffold = false,
    bool includeMaterialApp = false,

    /// When true, .index() without arguments will be called after setApp() is
    /// called.
    bool index = false,

    /// When set, .index() will be called with the given options.
    IndexOptions? indexOptions,
  }) async {
    final SetupSettings settings = SetupSettings(
      textDirection: textDirection,
      theme: theme,
      locale: locale,
      delegates: delegates,
      includeScaffold: includeScaffold,
      includeMaterialApp: includeMaterialApp,
    );

    final bool active = _root!.isActive;
    _rootKey = '$contextualType: $title';
    _root!.setRoot(root, settings: settings, keyName: _rootKey);
    if (!active) {
      await TestAsyncUtils.guard(() => bootstrapTester.pumpWidget(_root!));
    }
    await next();

    if (index || indexOptions != null) {
      this.index(options: indexOptions ?? IndexOptions());
    }
  }

  /// Index the current widget tree with several different options. Leave blank
  /// to index from the given root element, down.
  ///
  /// To include all widgets in the tree, set [includeSetupWidgets] to true.
  /// This may be helpful when trying to index objects called an automatically
  /// generated on the scaffold, for example.
  ///
  /// If a widget is large and complex, it is recommended to add specific
  /// filters with [indexKeys] and [indexTypes] to limit the amount of data indexed.
  ///
  /// Several options also help with debugging the indexed contents, such as
  /// [debugTree] and [debugContents].
  ///
  void index({
    /// Outputs to the console a tree of what will be indexed
    /// You can specify which types should be indexed with [debugTypeFilter]
    bool debugTree = false,

    /// Outputs to the console a simple view of keys, text and semantic labels
    /// for each widget
    bool debugContents = false,

    /// Only output to the tree these types and their children
    /// Must have debug tree flag on to work
    List<WidgetType> debugTypeFilter = const [],

    /// Only index these types and their children.
    ///
    /// Note [indexKeys] ignores types that do not match.
    /// Recommended to help with performance since searching will be faster.
    /// However double check that this list is correct as it will cause tests to
    /// fail if trying to search for a non-indexed type.
    List<WidgetType> indexTypes = const [],

    /// Only index these widgets and their children. Ignores [indexTypes] if
    /// the type does not match.
    ///
    /// Recommended to help with performance
    /// since searching will be faster. However double check that this list is correct
    /// as it will cause tests to fail if trying to search for a non-indexed type.
    List<Key> indexKeys = const [],

    /// By default, Error Widgets will throw when found. This can be disabled
    /// to allow the search to continue.
    bool warnOnErrorWidgets = true,

    /// By default, only the widget set in setApp will be indexed. This can be
    /// disabled to allow the search to index the entire tree.
    ///
    /// If setup includes scaffold or app widgets, it is recommended to include
    /// filters as the base app has a lot of widgets included.
    bool includeSetupWidgets = false,
    IndexOptions? options,
  }) {
    if (_root?.isActive == false) {
      throw 'App not initialized or is not ready yet. Call setApp() in an async first.';
    }

    // Map options to IndexOptions
    final IndexOptions options = IndexOptions(
      debugTree: debugTree,
      debugContents: debugContents,
      debugTypeFilter: debugTypeFilter,
      indexTypes: indexTypes,
      indexKeys: indexKeys,
      warnOnErrorWidgets: warnOnErrorWidgets,
      includeSetupWidgets: includeSetupWidgets,
    );
    _index(options);
  }

  void _index(IndexOptions options) {
    if (_rootKey == null) {
      throw 'App not initialized or is not ready yet. Call setApp() in an async first.';
    }

    Element rootElement;
    if (options.includeSetupWidgets) {
      rootElement = bootstrapTester.binding.rootElement!;
    } else {
      try {
        rootElement = bootstrapTester.firstElement(find.byKey(Key(_rootKey!)));
      } catch (e) {
        throw 'Failed to find root element: $_rootKey';
      }
    }

    final WidgetTree tree = WidgetTree(
      rootElement,
      indexOptions: options,
    );
    tree.index(options, bootstrapTester);
    _search = Search(tree);
  }

  /// Move forward the test environment to the next frame.
  /// This may not be enough for some use cases, such as animations. If needed,
  /// considering using [continue] instead.
  ///
  /// Equivalent to `pump` on the [WidgetTester]
  Future<void> forward({Duration? duration}) {
    return TestAsyncUtils.guard(() => bootstrapTester.pump(duration));
  }

  /// Continue the test environment to the next complete frame. Use this if
  /// [forward] is not enough.
  ///
  /// Equivalent to `pumpAndSettle` on the [WidgetTester]
  Future<void> next({Duration duration = const Duration(milliseconds: 100)}) {
    return TestAsyncUtils.guard(() => bootstrapTester.pumpAndSettle(duration));
  }

  /// Reset the test environment to a blank state. Use if [setApp] is not
  /// enough to reset the environment.
  Future<void> reset() async {
    _root!.clear();
    return next();
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
