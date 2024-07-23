part of '../cake_flutter.dart';

class Search {
  final WidgetTree _tree;
  Search(this._tree);

  /// Search the tree by key.
  ///
  /// Note this does a direct reference check, so this may not work well if
  /// you do not have a direct reference to the key. To search by contents of
  /// the key's value, use [keyText].
  TestElementWrapperCollection key(Key key) {
    return _tree.searchKey(key);
  }

  /// Search by the contents of a key's value. Use if you don't have a direct
  /// reference to the key.
  TestElementWrapperCollection keyText(String keyText) {
    return _tree.searchKeyText(keyText);
  }

  /// Search the tree by IconData used.
  TestElementWrapperCollection icon(IconData iconData) {
    return _tree.searchIcon(iconData);
  }

  /// Search the tree by for a specific, exact string.
  TestElementWrapperCollection text(String searchText) {
    return _tree.searchText(searchText);
  }

  /// Search the tree for a partial string.
  TestElementWrapperCollection textIncludes(String searchText) {
    return _tree.searchTextContaining(searchText);
  }

  /// Search the tree for a string matching a regular expression.
  TestElementWrapperCollection textMatch(RegExp searchRegEx) {
    return _tree.searchTextMatch(searchRegEx);
  }

  /// Search the tree by Widget type.
  TestElementWrapperCollection<W> type<W extends Widget>() {
    return _tree.searchType<W>();
  }
}
