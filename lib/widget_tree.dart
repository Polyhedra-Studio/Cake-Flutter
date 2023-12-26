part of '../cake_flutter.dart';

class WidgetTree extends _WidgetTree {
  final Element _rootElement;
  WidgetTree(this._rootElement);

  void index(WidgetTester tester) {
    elementWrapper = TestElementWrapper(_rootElement, tester);
    _findChildren(tester);
  }
}

class _WidgetTreeNode extends _WidgetTree {
  final Element nodeElement;
  final int depth;

  _WidgetTreeNode(this.nodeElement, {required this.depth});

  void create(WidgetTester tester) {
    elementWrapper = TestElementWrapper(nodeElement, tester);
    return _findChildren(tester, depth: depth + 1);
  }
}

abstract class _WidgetTree {
  late TestElementWrapper elementWrapper;
  final List<_WidgetTreeNode> _children = [];

  _WidgetTree();

  void _findChildren(WidgetTester tester, {int depth = 0}) {
    elementWrapper.element.visitChildren(
      (element) {
        _add(element, tester, depth: depth);
      },
    );
  }

  void _add(Element child, WidgetTester tester, {int depth = 0}) {
    final _WidgetTreeNode tree = _WidgetTreeNode(child, depth: depth);
    tree.create(tester);
    _children.add(tree);
    elementWrapper._addChild(tree.elementWrapper);
  }

  TestElementWrapper? searchKey(Key searchCriteria) {
    if (elementWrapper.key == searchCriteria) {
      return elementWrapper;
    }

    for (var element in _children) {
      final result = element.searchKey(searchCriteria);
      if (result != null) {
        return result;
      }
    }

    return null;
  }

  TestElementWrapperCollection searchText(String searchCriteria) {
    return _search((element) => element?.text == searchCriteria);
  }

  TestElementWrapperCollection searchIcon(IconData searchCriteria) {
    return _search((element) => element?.iconData == searchCriteria);
  }

  TestElementWrapperCollection<W> searchType<W extends Widget>([
    TestElementWrapperCollection<W>? collection,
  ]) {
    collection ??= TestElementWrapperCollection<W>();

    if (elementWrapper.widget is W) {
      collection.add(elementWrapper.asType<W>());
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

    if (searchMatcher(elementWrapper)) {
      collection.add(elementWrapper);
    }
    for (var element in _children) {
      element._search(searchMatcher, collection);
    }

    return collection;
  }
}
