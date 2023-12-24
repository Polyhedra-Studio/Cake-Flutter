part of '../cake_flutter.dart';

class Search {
  final WidgetTree _tree;
  Search(this._tree);

  TestElementWrapper? key(Key key) {
    return null;
  }

  TestElementWrapperCollection text(String searchText) {
    return _tree.searchText(searchText);
  }

  TestElementWrapperCollection icon(IconData iconData) {
    return _tree.searchIcon(iconData);
  }

  TestElementWrapperCollection<W> type<W extends Widget>() {
    return _tree.searchType<W>();
  }
}
