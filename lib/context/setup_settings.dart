part of '../cake_flutter.dart';

class SetupSettings {
  final TextDirection? _textDirection;
  TextDirection? get textDirection => _textDirection;
  final ThemeData? _theme;
  ThemeData? get theme => _theme;

  // Set delegates if locale is used and vice-versa
  final Locale? _locale;
  Locale? get locale {
    if (_locale == null && _delegates != null) {
      return const Locale('en', 'US');
    }
    return _locale;
  }

  final List<LocalizationsDelegate>? _delegates;
  List<LocalizationsDelegate>? get delegates {
    if (_delegates == null && _locale != null) {
      return <LocalizationsDelegate>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];
    }
    return _delegates;
  }

  final bool? _includeScaffold;
  bool get includeScaffold => _includeScaffold ?? false;

  final bool? _includeMaterialApp;
  // Scaffold needs a root material App base in order to work
  // Navigator observers need to be added to the material app
  bool get includeMaterialApp =>
      (_includeMaterialApp ?? false) ||
      (_includeScaffold ?? false) ||
      navigatorMocks.isNotEmpty;

  final Size? _surfaceSize;
  Size? get surfaceSize => _surfaceSize;

  final List<MockNavigationObserver>? _observers;
  List<MockNavigationObserver> get navigatorMocks =>
      _observers ?? <MockNavigationObserver>[];

  final bool? _includeNavigationObserver;
  bool get includeNavigationObserver => _includeNavigationObserver ?? false;

  const SetupSettings({
    TextDirection? textDirection,
    ThemeData? theme,
    Locale? locale,
    List<LocalizationsDelegate>? delegates,
    bool? includeScaffold,
    bool? includeMaterialApp,
    Size? surfaceSize,
    bool? includeNavigationMock,
    List<MockNavigationObserver>? navigationMocks,
  })  : _textDirection = textDirection,
        _theme = theme,
        _locale = locale,
        _delegates = delegates,
        _includeScaffold = includeScaffold,
        _includeMaterialApp = includeMaterialApp,
        _surfaceSize = surfaceSize,
        _includeNavigationObserver = includeNavigationMock,
        _observers = navigationMocks;

  SetupSettings fillWithParentOptions(SetupSettings? parentOptions) {
    if (parentOptions == null) {
      return this;
    }
    return SetupSettings(
      textDirection: _textDirection ?? parentOptions._textDirection,
      theme: _theme ?? parentOptions._theme,
      locale: _locale ?? parentOptions._locale,
      delegates: _delegates ?? parentOptions._delegates,
      includeScaffold: _includeScaffold ?? parentOptions._includeScaffold,
      includeMaterialApp:
          _includeMaterialApp ?? parentOptions._includeMaterialApp,
      surfaceSize: _surfaceSize ?? parentOptions._surfaceSize,
      includeNavigationMock: _includeNavigationObserver ??
          parentOptions._includeNavigationObserver,
      navigationMocks: _observers ?? parentOptions._observers,
    );
  }

  bool hasSameSettings(SetupSettings? other) {
    if (other == null) return false;
    return textDirection == other.textDirection &&
        theme == other.theme &&
        locale == other.locale &&
        delegates == other.delegates &&
        includeScaffold == other.includeScaffold &&
        includeMaterialApp == other.includeMaterialApp &&
        surfaceSize == other.surfaceSize &&
        includeNavigationObserver == other.includeNavigationObserver &&
        navigatorMocks == other.navigatorMocks;
  }

  @override
  String toString() {
    return '''
textDirection: $textDirection
theme: $theme
locale: $locale
delegates: $delegates
includeScaffold: $includeScaffold
includeMaterialApp: $includeMaterialApp
surfaceSize: $surfaceSize
includeNavigationObserver: $includeNavigationObserver
navigatorMocks: $navigatorMocks
    ''';
  }
}
