part of 'cake_flutter.dart';

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

  final bool _includeScaffold;
  bool get includeScaffold => _includeScaffold;

  final bool _includeMaterialApp;
  // Scaffold needs a root material App base in order to work
  bool get includeMaterialApp => _includeMaterialApp || _includeScaffold;

  const SetupSettings({
    TextDirection? textDirection,
    ThemeData? theme,
    Locale? locale,
    List<LocalizationsDelegate>? delegates,
    bool includeScaffold = false,
    bool includeMaterialApp = false,
  })  : _textDirection = textDirection,
        _theme = theme,
        _locale = locale,
        _delegates = delegates,
        _includeScaffold = includeScaffold,
        _includeMaterialApp = includeMaterialApp;

  bool hasSameSettings(SetupSettings? other) {
    if (other == null) return false;
    return textDirection == other.textDirection &&
        theme == other.theme &&
        locale == other.locale &&
        delegates == other.delegates &&
        includeScaffold == other.includeScaffold &&
        includeMaterialApp == other.includeMaterialApp;
  }
}
