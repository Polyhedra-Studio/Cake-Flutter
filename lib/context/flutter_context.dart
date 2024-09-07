part of '../../cake_flutter.dart';

class FlutterContext extends Context {
  FlutterTestOptions? _options;
  FlutterTestOptions? get options => _options;
  Search? _search;
  WidgetTester? _bootstrapTester;
  RootWidget? _root;
  Key? _rootKey;

  final List<Snapshot> snapshots = [];

  FlutterMockCollection? _mocks;

  @override
  FlutterMockCollection get mocks {
    _mocks ??= FlutterMockCollection();
    return _mocks!;
  }

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
      CakeFlutterError(
        'App not initialized or is not ready yet. Call setApp() in an async first.',
      );
    }
    return _bootstrapTester!;
  }

  // Bootstrap tester is provided once this is copied from the parent
  // OnComplete should only be called once from the TestRunner
  FlutterContext._child({required FlutterTestOptions? options})
      : _options = options;

  FlutterContext._({
    required FlutterTestOptions? options,
    required WidgetTester tester,
  })  : _options = options,
        _bootstrapTester = tester,
        _root = RootWidget();

  @override
  void copyExtraParams(Context contextToCopyFrom) {
    if (contextToCopyFrom is FlutterContext) {
      _bootstrapTester = contextToCopyFrom._bootstrapTester;
      _search = contextToCopyFrom._search;
      _root = contextToCopyFrom._root;
      _rootKey = contextToCopyFrom._rootKey;
      _options = _options?.mapParentFlutterOptions(contextToCopyFrom.options) ??
          contextToCopyFrom.options;
      if (contextToCopyFrom._mocks != null) {
        mocks.addAllFromOther(contextToCopyFrom.mocks);
      }
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
  /// If [index] is true or if [indexOptions] are provided, the widget will be
  /// indexed after setup.
  ///
  /// If [snapshot] is true or if [snapshotOptions] are provided, a snapshot
  /// will be taken immediately after setup.
  ///
  /// Include [surfaceSize] to set the size of the working surface.
  Future<void> setApp(
    Widget root, {
    TextDirection? textDirection,
    ThemeData? theme,
    Locale? locale,
    List<LocalizationsDelegate>? delegates,
    bool? includeScaffold,
    bool? includeMaterialApp,
    Size? surfaceSize,
    List<MockNavigationObserver>? navigationMocks,
    bool? includeNavigationMock,

    /// When true, .index() without arguments will be called after setApp() is
    /// called.
    bool index = false,

    /// When set, .index() will be called with the given options.
    IndexOptions? indexOptions,

    /// When true, a snapshot will be taken immediately after setApp() is called.
    bool snapshot = false,

    /// When set, .snapshot() will be called with the given options.
    SnapshotOptions? snapshotOptions,
  }) async {
    SetupSettings settings = SetupSettings(
      textDirection: textDirection,
      theme: theme,
      locale: locale,
      delegates: delegates,
      includeScaffold: includeScaffold,
      includeMaterialApp: includeMaterialApp,
      surfaceSize: surfaceSize,
      includeNavigationMock: includeNavigationMock,
      navigationMocks: navigationMocks,
    );
    settings = settings.fillWithParentOptions(options?.setupSettings);

    List<NavigatorObserver>? observers;

    if (settings.navigatorMocks.isNotEmpty ||
        settings.includeNavigationObserver == true) {
      observers = mocks.setNavigationMocks(settings);
    }

    if (settings.surfaceSize != null) {
      await tester.binding.setSurfaceSize(settings.surfaceSize);
    }

    final bool active = _root!.isActive;
    _rootKey = Key('$contextualType: $title');
    _root!.setRoot(
      root,
      settings: settings,
      key: _rootKey!,
      observers: observers,
    );

    if (!active) {
      await TestAsyncUtils.guard(() => bootstrapTester.pumpWidget(_root!));
    }
    await next();

    if (index || indexOptions != null) {
      _index(indexOptions ?? IndexOptions());
    }

    if (snapshot || snapshotOptions != null) {
      snapshotOptions = SnapshotOptions.fromParent(
        parentOptions: options?.snapshotOptions,
      );
    }

    if (snapshotOptions != null) {
      await _snapshot(snapshotOptions);
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
      throw CakeFlutterError.notInitialized(thrownOn: 'index()');
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
      throw CakeFlutterError.notInitialized(thrownOn: 'index()');
    }

    Element rootElement;
    if (options.includeSetupWidgets) {
      rootElement = bootstrapTester.binding.rootElement!;
    } else {
      try {
        rootElement = bootstrapTester.firstElement(find.byKey(_rootKey!));
      } catch (e) {
        throw CakeFlutterError(
          'Failed to find root element: $_rootKey',
          hint:
              'The element tree might be in a bad state. Try calling reset() along with setApp() if this issue persists.',
          thrownOn: 'index()',
        );
      }
    }

    final WidgetTree tree = WidgetTree(
      rootElement,
      indexOptions: options,
    );
    tree.index(options, bootstrapTester, onSnapshot: snapshot);
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
    return TestAsyncUtils.guard(
      () async {
        try {
          await bootstrapTester.pumpAndSettle(duration);
        } on FlutterError catch (e) {
          if (e.message == 'pumpAndSettle timed out') {
            // Give a more helpful error message on how to proceed. This is
            // often caused by an infinite animation or nested builders.
            throw CakeFlutterError(
              'pumpAndSettle timed out.',
              hint:
                  'There may be an infinite animation or asynchronous operation still running. Consider using forward() with a duration instead. Note that the test may be in an unstable state and should have reset() called on teardown.',
              thrownOn: 'next()',
            );
          }
          rethrow;
        }
      },
    );
  }

  /// Reset the test environment to a blank state. Use if [setApp] is not
  /// enough to reset the environment.
  Future<void> reset() async {
    _root!.clear();
    return next();
  }

  /// Creates a snapshot of the current state of the test environment. Snapshot
  /// options are inherited from parents.
  ///
  /// Use [includeSetupWidgets] to include setup widgets in the snapshot, else
  /// the snapshot will only include the root widget. Defaults to false.
  ///
  /// Use [createIfMissing] to create the snapshot if it does not exist. Defaults
  /// to true.
  ///
  /// Use [createCopyIfMismatch] to create a copy of the snapshot if it does not
  /// match. Defaults to true.
  /// Use [mismatchDirectory] and [mismatchFileName] to specify a directory and
  /// file name to create a copy of the snapshot if it does not match. Defaults
  /// to the same directory and file name as the snapshot with "_mismatch" appended.
  ///
  /// Use [overwriteGolden] to overwrite the current golden file if it exists.
  /// Defaults to false.
  ///
  /// Use [directory] and [fileName] to specify a directory and file name to
  /// create the snapshot in. Defaults to "test/snapshots" and the test name.
  ///
  /// Use [fontFamily] to specify the font family to use in the snapshot. By
  /// default, Flutter uses a blocky placeholder font called "Ahem" (pre-3.7)
  /// or "FlutterTest" (3.7 and later). If you want to use a custom font
  /// family, make sure to load it first, then pass the family name here.
  ///
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
    bool? warnIfInvalid,
    Widget? snapshotWidget,
    SetupSettings? snapshotWidgetSetup,
  }) async {
    if (_root == null && warnIfInvalid != false) {
      throw CakeFlutterError.notInitialized(thrownOn: 'snapshot()');
    }
    if (options?.snapshotOptions?.skipSnapshots == true) return null;

    final SnapshotOptions snapshotOptions = SnapshotOptions.fromParent(
      includeSetupWidgets: includeSetupWidgets,
      createIfMissing: createIfMissing,
      createCopyIfMismatch: createCopyIfMismatch,
      mismatchDirectory: mismatchDirectory,
      mismatchFileName: mismatchFileName,
      overwriteGolden: overwriteGolden,
      directory: directory,
      fileName: fileName,
      parentOptions: options?.snapshotOptions,
    );

    return _snapshot(
      snapshotOptions,
      warnIfInvalid: warnIfInvalid,
      snapshotWidget: snapshotWidget,
      snapshotWidgetSetup: snapshotWidgetSetup,
    );
  }

  Future<Snapshot?> _snapshot(
    SnapshotOptions snapshotOptions, {
    bool? warnIfInvalid = true,
    Widget? snapshotWidget,
    SetupSettings? snapshotWidgetSetup,
  }) async {
    if (options?.snapshotOptions?.skipSnapshots == true) return null;

    // Set in a snapshot state
    mocks.pause();
    _root?.snapshot(
      snapshotOptions,
      snapshotWidget: snapshotWidget,
      snapshotWidgetSetup: snapshotWidgetSetup,
    );
    await next();

    // Take picture
    final RenderRepaintBoundary? boundary = _root!.snapshotKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      if (warnIfInvalid != false) {
        throw CakeFlutterError(
          'Could not find RenderRepaintBoundary for snapshot.',
          hint:
              'Ensure that the widget used is a valid Flutter widget that has a RenderObject. If it is valid, the widget tree might be in a bad state. Try calling reset() along with setApp() if this issue persists.',
          thrownOn: 'snapshot()',
        );
      } else {
        return null;
      }
    }

    final Snapshot snapshot = Snapshot(
      testName: title,
      options: snapshotOptions,
    );
    await snapshot.create(boundary);
    snapshots.add(snapshot);

    // Restore to state before snapshot
    _root?.restore();
    await next();
    mocks.resume();

    return snapshot;
  }

  /// Set the size of the working surface.
  ///
  /// This is equivalent to calling [TestWidgetsFlutterBinding.setSurfaceSize]
  /// in the test environment. You can also use the [surfaceSize] parameter in
  /// the [setApp] method to do this as well.
  ///
  /// Note that this does not reset after the test is complete. Remember to set
  /// the size back to the original size after the test is complete, if that is
  /// the desired behavior.
  Future<void> setSurfaceSize(Size? size) async {
    return TestAsyncUtils.guard(() async {
      tester.binding.setSurfaceSize(size);
    });
  }

  /// A helper method to load fonts for testing
  ///
  /// Note that if [loadFontForErrors] is true, then FlutterError.onError will
  /// be overridden.
  Future<void> loadFont(
    String fontFamily, {
    required Future<ByteData> fontData,
    bool loadFontForErrors = true,
  }) {
    if (loadFontForErrors) {
      FlutterError.onError = (details) async {
        FlutterError.dumpErrorToConsole(details);
        await setApp(
          DisplayableErrorWidget(
            details,
            fontFamily: fontFamily,
          ),
        );
      };
    }
    final FontLoader fontLoader = FontLoader(fontFamily)..addFont(fontData);
    return TestAsyncUtils.guard(() => fontLoader.load());
  }

  /// A helper method to load fonts for testing
  ///
  /// Note that if [loadFontForErrors] is true, then FlutterError.onError will
  /// be overridden.
  Future<void> loadFontFromBundle(
    String fontFamily, {
    required AssetBundle bundle,
    required String path,
    bool loadFontForErrors = true,
  }) {
    return loadFont(
      fontFamily,
      fontData: bundle.load(path),
      loadFontForErrors: loadFontForErrors,
    );
  }
}
