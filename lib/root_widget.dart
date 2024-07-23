part of 'cake_flutter.dart';

class RootWidget extends StatefulWidget {
  final StreamController<RootWidgetConfiguration?> root =
      StreamController<RootWidgetConfiguration?>();

  bool get isActive => root.hasListener;

  RootWidget({super.key});

  void setRoot(
    Widget newRootWidget, {
    SetupSettings? settings,
    String? keyName,
  }) {
    root.add(
      RootWidgetConfiguration(
        root: newRootWidget,
        keyName: keyName,
        settings: settings,
      ),
    );
  }

  void clear() {
    root.add(null);
  }

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  Widget? _rootWidget;
  SetupSettings? _settings;
  Key? _rootKeyName;

  @override
  void initState() {
    super.initState();

    widget.root.stream.listen((event) {
      if (event == null) {
        setState(() {
          _rootWidget = null;
          _rootKeyName = null;
        });
      } else {
        setState(() {
          _rootWidget = event.root;
          if (event.keyName == null) {
            _rootKeyName = null;
          } else {
            _rootKeyName = Key(event.keyName!);
          }

          if (_settings == null ||
              !_settings!.hasSameSettings(event.settings)) {
            _settings = event.settings;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.root.close();
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null && _rootWidget == null) {
      return Container();
    }
    if (_settings == null) {
      return _rootWidget!;
    }

    Widget app = Container(
      key: _rootKeyName,
      child: _rootWidget,
    );

    // RTL is not the default, so this should be set regardless of other flags.
    if (_settings!.textDirection == TextDirection.rtl) {
      app = Directionality(textDirection: TextDirection.rtl, child: app);
    }

    // These widgets are normally included with Material or Cupertino, but
    // without the root app, they are included here.
    if (!_settings!.includeMaterialApp) {
      // LTR is the default, so Material and Cupertino already do this.
      if (_settings!.textDirection == TextDirection.ltr) {
        app = Directionality(textDirection: TextDirection.ltr, child: app);
      }

      if (_settings!.theme != null) {
        app = Theme(data: _settings!.theme!, child: app);
      }

      if (_settings!.delegates != null) {
        app = Localizations(
          locale: _settings!.locale!,
          delegates: _settings!.delegates!,
          child: app,
        );
      }
    }

    if (_settings!.includeScaffold) {
      app = Scaffold(body: app);
    }

    // Base Material or Cupertino app
    if (_settings!.includeMaterialApp) {
      app = MaterialApp(
        home: app,
        theme: _settings!.theme,
        locale: _settings!.locale,
        localizationsDelegates: _settings!.delegates,
      );
    }

    return app;
  }
}

class RootWidgetConfiguration {
  final Widget? root;
  final String? keyName;
  final SetupSettings? settings;
  RootWidgetConfiguration({
    required this.root,
    required this.keyName,
    required this.settings,
  });
}
