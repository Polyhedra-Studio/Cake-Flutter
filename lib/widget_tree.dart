part of '../cake_flutter.dart';

class WidgetTree extends _WidgetTree {
  final Element _rootElement;
  WidgetTree(this._rootElement, {required super.indexOptions});

  void index(IndexOptions indexOptions, WidgetTester tester) {
    elementWrapper = TestElementWrapper(_rootElement, tester);
    if (indexOptions.matchesIndexFilter(_rootElement)) {
      parentMatchesIndexFilter = true;
    }
    _WidgetTree._findChildren(
      this,
      _rootElement,
      tester,
    );
  }
}

class _WidgetTreeNode extends _WidgetTree {
  final Element nodeElement;

  _WidgetTreeNode(
    this.nodeElement, {
    required super.debugDepth,
    super.parentMatchesDebugFilter,
    required super.indexOptions,
  }) : super(parentMatchesIndexFilter: true);

  void create(WidgetTester tester) {
    elementWrapper = TestElementWrapper(nodeElement, tester);

    // Check if this node should be printed for debugging
    if (indexOptions.matchesDebugFilter(nodeElement) ||
        parentMatchesDebugFilter) {
      String message = debugDepth > 0 ? '|' : '';
      for (int i = 0; i < debugDepth; i++) {
        message += ' ';
      }
      message += 'Found: ${nodeElement.widget.runtimeType}';
      // ignore: avoid_print
      print(message);
      parentMatchesDebugFilter = true;
    }

    _WidgetTree._findChildren(
      this,
      nodeElement,
      tester,
      debugDepth: parentMatchesDebugFilter ? debugDepth + 1 : 0,
    );
  }
}

abstract class _WidgetTree {
  TestElementWrapper? elementWrapper;
  final List<_WidgetTreeNode> _children = [];
  bool parentMatchesIndexFilter;
  bool parentMatchesDebugFilter;
  final int debugDepth;
  IndexOptions indexOptions;

  _WidgetTree({
    required this.indexOptions,
    this.debugDepth = 0,
    this.parentMatchesIndexFilter = false,
    this.parentMatchesDebugFilter = false,
  });

  static void _findChildren(
    _WidgetTree tree,
    Element parentElement,
    WidgetTester tester, {
    int debugDepth = 0,
  }) {
    parentElement.visitChildren(
      (element) {
        _add(tree, element, tester, debugDepth: debugDepth);
      },
    );
  }

  static void _add(
    _WidgetTree tree,
    Element child,
    WidgetTester tester, {
    int debugDepth = 0,
  }) {
    if (tree.parentMatchesIndexFilter ||
        tree.indexOptions.matchesIndexFilter(child)) {
      final _WidgetTreeNode node = _WidgetTreeNode(
        child,
        debugDepth: debugDepth,
        parentMatchesDebugFilter: tree.parentMatchesDebugFilter,
        indexOptions: tree.indexOptions,
      );
      node.create(tester);
      tree.addChild(node);
    } else {
      _findChildren(tree, child, tester);
    }
  }

  void addChild(_WidgetTreeNode child) {
    _children.add(child);
    elementWrapper?._addChild(child.elementWrapper!);
  }

  TestElementWrapper? searchKey(Key searchCriteria) {
    if (elementWrapper?.key == searchCriteria) {
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
    // Ensure that this type was indexed in the first place
    if (!indexOptions.hasIndexedType<W>()) {
      throw '$W has not been indexed! Searching by type will fail without it.\nEither add WidgetType<$W>() to indexFilter or remove all filters.\n';
    }

    collection ??= TestElementWrapperCollection<W>();

    if (elementWrapper?.widget is W) {
      collection.add(elementWrapper!.asType<W>());
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

    if (elementWrapper != null && searchMatcher(elementWrapper)) {
      collection.add(elementWrapper!);
    }
    for (var element in _children) {
      element._search(searchMatcher, collection);
    }

    return collection;
  }
}
