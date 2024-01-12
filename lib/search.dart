part of '../cake_flutter.dart';

class Search {
  final WidgetTree _tree;
  Search(this._tree);

  TestElementWrapperCollection key(Key key) {
    return _tree.searchKey(key);
  }

  TestElementWrapperCollection icon(IconData iconData) {
    return _tree.searchIcon(iconData);
  }

  TestElementWrapperCollection text(String searchText) {
    return _tree.searchText(searchText);
  }

  TestElementWrapperCollection<W> type<W extends Widget>() {
    return _tree.searchType<W>();
  }
}
