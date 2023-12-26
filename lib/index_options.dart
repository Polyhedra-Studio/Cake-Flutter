part of '../cake_flutter.dart';

class IndexOptions {
  /// Outputs to the console a tree of what will be indexed
  /// You can specify which types should be indexed with [debugTypeFilter]
  final bool debugTree;

  /// Only output to the tree these types and their children
  /// Must have debug tree flag on to work
  final List<WidgetType> debugTypeFilter;

  /// Only index these types and their children. Recommended to help with performance
  /// since searching will be faster. However double check that this list is correct
  /// as it will cause tests to fail if trying to search for a non-indexed type.
  final List<WidgetType> indexFilter;

  /// Helper for common search types for Text and Icons
  static const List<WidgetType> defaultSearchTypes = [
    WidgetType<Text>(),
    WidgetType<Icon>(),
  ];

  IndexOptions({
    this.debugTree = false,
    this.debugTypeFilter = const [],
    this.indexFilter = const [],
  });

  bool matchesIndexFilter(Element element) {
    if (indexFilter.isEmpty) {
      return true;
    } else {
      return indexFilter.any((filterElement) => filterElement.match(element));
    }
  }

  bool matchesDebugFilter(Element element) {
    if (debugTree == false) {
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
    if (indexFilter.isEmpty) {
      return true;
    } else {
      return indexFilter.any((filterElement) => filterElement.matchType<W2>());
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
