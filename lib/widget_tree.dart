import 'package:cake_flutter/test_element_wrapper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class WidgetTree extends _WidgetTree {
  final Element _rootElement;
  WidgetTree(this._rootElement);

  void index(WidgetTester tester) {
    _findChildren(_rootElement, tester);
  }
}

class _WidgetTreeNode extends _WidgetTree {
  final Element nodeElement;
  final int depth;

  _WidgetTreeNode(this.nodeElement, {required this.depth});

  void create(WidgetTester tester) {
    _elementWrapper = TestElementWrapper(nodeElement, tester);
    return _findChildren(nodeElement, tester, depth: depth + 1);
  }
}

abstract class _WidgetTree {
  TestElementWrapper? _elementWrapper;
  final List<_WidgetTreeNode> _children = [];

  _WidgetTree();

  void _findChildren(Element element, WidgetTester tester, {int depth = 0}) {
    element.visitChildren(
      (element) {
        _add(element, tester, depth: depth);
      },
    );
  }

  void _add(Element child, WidgetTester tester, {int depth = 0}) {
    final _WidgetTreeNode tree = _WidgetTreeNode(child, depth: depth);
    tree.create(tester);
    _children.add(tree);
  }

  TestElementWrapperCollection searchText(
    String searchCriteria, [
    TestElementWrapperCollection? collection,
  ]) {
    return _search((element) => element?.text == searchCriteria);
  }

  TestElementWrapperCollection searchIcon(
    IconData searchCriteria, [
    TestElementWrapperCollection? collection,
  ]) {
    return _search((element) => element?.iconData == searchCriteria);
  }

  TestElementWrapperCollection<W> searchType<W extends Widget>([
    TestElementWrapperCollection<W>? collection,
  ]) {
    collection ??= TestElementWrapperCollection<W>();

    if (_elementWrapper?.widget is W) {
      collection.add(_elementWrapper!.asType<W>());
    }

    for (var element in _children) {
      element.searchType<W>(collection);
    }

    return collection;
  }

  TestElementWrapperCollection _search<W extends Widget>(
    bool Function(TestElementWrapper? element) searchMatcher, [
    TestElementWrapperCollection? collection,
  ]) {
    collection ??= TestElementWrapperCollection();

    if (searchMatcher(_elementWrapper)) {
      collection.add(_elementWrapper!);
    }
    for (var element in _children) {
      element._search(searchMatcher, collection);
    }

    return collection;
  }
}
