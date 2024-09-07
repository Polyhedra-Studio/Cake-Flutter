part of '../../cake_flutter.dart';

class IndexOptions {
  /// Outputs to the console a tree of what will be indexed
  /// You can specify which types should be indexed with [debugTypeFilter]
  final bool debugTree;

  /// Outputs to the console a simple view of keys, text and semantic labels
  /// for each widget
  final bool debugContents;

  /// Only output to the tree these types and their children
  /// Must have debug tree flag on to work
  final List<WidgetType> debugTypeFilter;

  /// Only index these types and their children.
  ///
  /// Note [indexKeys] ignores types that do not match.
  /// Recommended to help with performance since searching will be faster.
  /// However double check that this list is correct as it will cause tests to
  /// fail if trying to search for a non-indexed type.
  final List<WidgetType> indexTypes;

  /// Only index these widgets and their children. Ignores [indexTypes] if
  /// the type does not match.
  ///
  /// Recommended to help with performance
  /// since searching will be faster. However double check that this list is correct
  /// as it will cause tests to fail if trying to search for a non-indexed type.
  final List<Key> indexKeys;

  /// Helper for common search types for Text and Icons
  static const List<WidgetType> defaultSearchTypes = [
    WidgetType<Text>(),
    WidgetType<Icon>(),
  ];

  /// By default, Error Widgets will throw when found. This can be disabled
  /// to allow the search to continue.
  final bool warnOnErrorWidgets;

  /// By default, only the widget set in setApp will be indexed. This can be
  /// disabled to allow the search to index the entire tree.
  final bool includeSetupWidgets;

  IndexOptions({
    this.debugTree = false,
    this.debugContents = false,
    this.debugTypeFilter = const [],
    this.indexTypes = const [],
    this.indexKeys = const [],
    this.warnOnErrorWidgets = true,
    this.includeSetupWidgets = false,
  });

  void checkForErrorWidgets(Element element) {
    if (element.widget is ErrorWidget && warnOnErrorWidgets) {
      final String widgetMessage = (element.widget as ErrorWidget).message;
      throw CakeFlutterError(
        'Found an ErrorWidget with the following message:\n$widgetMessage',
        hint:
            'To ignore this and continue, set IndexOptions.warnOnErrorWidgets to false',
      );
    }
  }

  bool matchesIndexFilter(Element element) {
    if (indexTypes.isEmpty && indexKeys.isEmpty) {
      return true;
    }

    // Make sure to record any ErrorWidgets
    if (warnOnErrorWidgets && element.widget is ErrorWidget) {
      return true;
    }

    if (indexKeys.isNotEmpty) {
      final bool keyMatch =
          indexKeys.any((filterKey) => filterKey == element.widget.key);
      if (keyMatch) {
        return true;
      }
    }

    if (indexTypes.isNotEmpty) {
      return indexTypes.any((filterElement) => filterElement.match(element));
    }

    return false;
  }

  bool matchesDebugFilter(Element element) {
    if (debugTree == false && debugContents == false) {
      return false;
    }

    if (debugTypeFilter.isEmpty) {
      return true;
    } else {
      return debugTypeFilter
          .any((filterElement) => filterElement.match(element));
    }
  }

  bool hasIndexedType<W2 extends Widget>() {
    if (indexTypes.isEmpty) {
      return true;
    } else {
      return indexTypes.any((filterElement) => filterElement.matchType<W2>());
    }
  }
}

class WidgetType<T extends Widget> {
  const WidgetType();

  bool match(Element element) {
    return element.widget is T;
  }

  bool matchType<W2 extends Widget>() {
    return T == W2;
  }
}
