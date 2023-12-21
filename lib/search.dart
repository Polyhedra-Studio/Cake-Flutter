import 'package:cake_flutter/test_element_wrapper.dart';
import 'package:cake_flutter/widget_tree.dart';
import 'package:flutter/widgets.dart';

class Search {
  final WidgetTreeRoot _tree;
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
