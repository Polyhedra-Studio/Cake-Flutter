part of '../cake_flutter.dart';

class RootWidget extends StatefulWidget {
  final StreamController<_RootConfiguration> _root =
      StreamController<_RootConfiguration>();
  final GlobalKey snapshotKey = GlobalKey();

  bool get isActive => _root.hasListener;

  RootWidget({super.key});

  void setRoot(
    Widget newRootWidget, {
    required SetupSettings settings,
    required Key key,
    required List<NavigatorObserver>? observers,
  }) {
    _root.add(
      _RootConfigSetup(
        root: newRootWidget,
        key: key,
        settings: settings,
        observers: observers,
      ),
    );
  }

  void snapshot(
    SnapshotOptions options, {
    required Widget? snapshotWidget,
    required SetupSettings? snapshotWidgetSetup,
  }) {
    _root.add(
      _RootConfigSnapshot(
        snapshotOptions: options,
        root: snapshotWidget,
        settings: snapshotWidgetSetup,
      ),
    );
  }

  void restore() {
    _root.add(_RootConfiguration.restore());
  }

  void clear() {
    _root.add(_RootConfiguration.clear());
  }

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  Widget? _rootWidget;
  SetupSettings? _settings;
  SnapshotOptions? _snapshotOptions;
  SetupSettings? _lastConfigurationSetup;
  Widget? _lastWidget;
  List<NavigatorObserver>? _observers;

  @override
  void initState() {
    super.initState();

    widget._root.stream.listen((event) {
      _snapshotOptions = null;

      switch (event.mode) {
        case _ConfigurationMode.clear:
          return _clear();
        case _ConfigurationMode.setup:
          return _setup(event as _RootConfigSetup);
        case _ConfigurationMode.snapshot:
          return _snapshot(event as _RootConfigSnapshot);
        case _ConfigurationMode.restore:
          return _restore();
      }
    });
  }

  void _clear() {
    setState(() {
      _rootWidget = null;
      _settings = null;
      _observers = null;
    });
  }

  void _setup(_RootConfigSetup config) {
    // Set up root app with keys to preserve state when needed
    final Widget newRoot = KeyedSubtree(
      key: GlobalKey(),
      child: KeyedSubtree(
        key: config.key,
        child: config.root,
      ),
    );

    // Only change up the settings if it has changed, for performance
    if (_settings == null ||
        _settings?.hasSameSettings(config.settings) == false) {
      _settings = config.settings;
    }

    setState(() {
      _rootWidget = newRoot;
      _observers = config.observers;
    });
  }

  void _snapshot(_RootConfigSnapshot config) {
    // Create Snapshot state
    setState(() {
      _snapshotOptions = config.snapshotOptions;

      if (config.root != null) {
        // Store last configuration so we can restore in the next step
        _lastWidget = _rootWidget;
        _rootWidget = config.root;
      }

      if (config.settings != null &&
          (_settings == null ||
              _settings?.hasSameSettings(config.settings) == false)) {
        _lastConfigurationSetup = _settings;
        _settings = config.settings;
      }
    });
  }

  void _restore() {
    setState(() {
      _snapshotOptions = null;

      if (_lastConfigurationSetup != null) {
        _settings = _lastConfigurationSetup;
        _lastConfigurationSetup = null;
      }
      if (_lastWidget != null) {
        _rootWidget = _lastWidget;
        _lastWidget = null;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget._root.close();
  }

  @override
  Widget build(BuildContext context) {
    Widget app = _rootWidget ?? Container();

    if (_settings == null && _snapshotOptions == null) {
      return app;
    }

    if (_snapshotOptions?.includeSetupWidgets == false) {
      app = RepaintBoundary(
        key: widget.snapshotKey,
        child: app,
      );
    }

    if (_snapshotOptions?.fontFamily != null) {
      app = DefaultTextStyle(
        style: TextStyle(
          fontFamily: _snapshotOptions?.fontFamily,
        ),
        child: app,
      );
    }

    // RTL is not the default, so this should be set regardless of other flags.
    if (_settings?.textDirection == TextDirection.rtl) {
      app = Directionality(textDirection: TextDirection.rtl, child: app);
    }

    // These widgets are normally included with Material or Cupertino, but
    // without the root app, they are included here.
    if (_settings?.includeMaterialApp == false) {
      // LTR is the default, so Material and Cupertino already do this.
      if (_settings!.textDirection == TextDirection.ltr) {
        app = Directionality(textDirection: TextDirection.ltr, child: app);
      }

      if (_settings?.theme != null) {
        app = Theme(data: _settings!.theme!, child: app);
      }

      if (_settings?.delegates != null) {
        app = Localizations(
          locale: _settings!.locale!,
          delegates: _settings!.delegates!,
          child: app,
        );
      }
    }

    if (_settings?.includeScaffold == true) {
      app = Scaffold(body: app);
    }

    // Base Material or Cupertino app
    if (_settings?.includeMaterialApp == true) {
      app = MaterialApp(
        home: app,
        theme: _settings!.theme,
        locale: _settings!.locale,
        localizationsDelegates: _settings!.delegates,
        navigatorObservers: _observers ?? [],
      );
    }

    if (_snapshotOptions?.includeSetupWidgets == true) {
      app = RepaintBoundary(
        key: widget.snapshotKey,
        child: app,
      );
    }

    return app;
  }
}

class RootWidgetConfiguration {
  final Widget? root;
  final String? keyName;
  final SetupSettings? settings;
  final SnapshotOptions? snapshotOptions;
  final bool? restoreLastConfiguration;

  RootWidgetConfiguration({
    this.root,
    this.keyName,
    this.settings,
    this.snapshotOptions,
    this.restoreLastConfiguration,
  });
}

enum _ConfigurationMode {
  setup,
  snapshot,
  restore,
  clear,
}

class _RootConfiguration {
  final _ConfigurationMode mode;

  _RootConfiguration._({required this.mode});

  factory _RootConfiguration.restore() => _RootConfiguration._(
        mode: _ConfigurationMode.restore,
      );

  factory _RootConfiguration.clear() => _RootConfiguration._(
        mode: _ConfigurationMode.clear,
      );
}

class _RootConfigSetup extends _RootConfiguration {
  Key key;
  Widget root;
  SetupSettings? settings;
  List<NavigatorObserver>? observers;

  _RootConfigSetup({
    required this.root,
    required this.key,
    required this.settings,
    required this.observers,
  }) : super._(mode: _ConfigurationMode.setup);
}

class _RootConfigSnapshot extends _RootConfiguration {
  Widget? root;
  SnapshotOptions snapshotOptions;
  SetupSettings? settings;

  _RootConfigSnapshot({
    required this.root,
    required this.settings,
    required this.snapshotOptions,
  }) : super._(mode: _ConfigurationMode.snapshot);
}
