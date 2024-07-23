part of '../cake_flutter.dart';

class WidgetTree extends _WidgetTree {
  final Element _rootElement;
  WidgetTree(this._rootElement, {required super.indexOptions});

  void index(IndexOptions indexOptions, WidgetTester tester) {
    elementWrapper = TestElementWrapper(_rootElement, tester);
    if (indexOptions.matchesIndexFilter(_rootElement)) {
      parentMatchesIndexFilter = true;
    }

    if (indexOptions.debugContents) {
      debugContents = [];
    }

    _WidgetTree._findChildren(
      this,
      _rootElement,
      tester,
      debugContents: debugContents,
    );

    if (debugContents?.isNotEmpty == true) {
      debugContents?.forEach(
        // ignore: avoid_print
        (message) => print(message),
      );
    }
  }
}

class _WidgetTreeNode extends _WidgetTree {
  final Element nodeElement;

  _WidgetTreeNode(
    this.nodeElement, {
    required super.debugDepth,
    required super.debugContents,
    super.parentMatchesDebugFilter,
    required super.indexOptions,
  }) : super(parentMatchesIndexFilter: true);

  void create(WidgetTester tester) {
    elementWrapper = TestElementWrapper(nodeElement, tester);

    // Check if this node should be printed for debugging
    if (indexOptions.matchesDebugFilter(nodeElement) ||
        parentMatchesDebugFilter) {
      String spacing = debugDepth > 0 ? '|' : '';
      for (int i = 0; i < debugDepth; i++) {
        spacing += ' ';
      }

      if (indexOptions.debugTree) {
        final String message =
            '${spacing}Found: ${nodeElement.widget.runtimeType}';
        // ignore: avoid_print
        print(message);
      }

      // Append specific debug message
      if (indexOptions.debugContents) {
        // Print Key names
        if (nodeElement.widget.key != null) {
          debugContents?.add(spacing + nodeElement.widget.key.toString());
        }

        // Print Text content
        String? widgetDisplay;
        if (nodeElement.widget is Text) {
          widgetDisplay = (nodeElement.widget as Text).data ?? '(Empty Text)';
        }
        if (widgetDisplay != null) {
          debugContents?.add(spacing + widgetDisplay);
        }
      }

      parentMatchesDebugFilter = true;
    }

    _WidgetTree._findChildren(
      this,
      nodeElement,
      tester,
      debugDepth: parentMatchesDebugFilter ? debugDepth + 1 : 0,
      debugContents: debugContents,
    );
  }
}

abstract class _WidgetTree {
  TestElementWrapper? elementWrapper;
  final List<_WidgetTreeNode> _children = [];
  bool parentMatchesIndexFilter;
  bool parentMatchesDebugFilter;
  final int debugDepth;
  List<String>? debugContents;
  IndexOptions indexOptions;

  _WidgetTree({
    required this.indexOptions,
    this.debugDepth = 0,
    this.debugContents,
    this.parentMatchesIndexFilter = false,
    this.parentMatchesDebugFilter = false,
  });

  static void _findChildren(
    _WidgetTree tree,
    Element parentElement,
    WidgetTester tester, {
    int debugDepth = 0,
    required List<String>? debugContents,
  }) {
    parentElement.visitChildren(
      (element) {
        _add(
          tree,
          element,
          tester,
          debugDepth: debugDepth,
          debugContents: debugContents,
        );
      },
    );
  }

  static void _add(
    _WidgetTree tree,
    Element child,
    WidgetTester tester, {
    int debugDepth = 0,
    required List<String>? debugContents,
  }) {
    tree.indexOptions.checkForErrorWidgets(child);

    if (tree.parentMatchesIndexFilter ||
        tree.indexOptions.matchesIndexFilter(child)) {
      final _WidgetTreeNode node = _WidgetTreeNode(
        child,
        debugDepth: debugDepth,
        debugContents: debugContents,
        parentMatchesDebugFilter: tree.parentMatchesDebugFilter,
        indexOptions: tree.indexOptions,
      );
      node.create(tester);
      tree.addChild(node);
    } else {
      _findChildren(tree, child, tester, debugContents: debugContents);
    }
  }

  void addChild(_WidgetTreeNode child) {
    _children.add(child);
    elementWrapper?._addChild(child.elementWrapper!);
  }

  TestElementWrapperCollection searchKey(Key searchCriteria) {
    return _search((element) => element?.key == searchCriteria);
  }

  TestElementWrapperCollection searchKeyText(String searchCriteria) {
    return _search((element) => element?.keyText == searchCriteria);
  }

  TestElementWrapperCollection searchText(String searchCriteria) {
    return _search((element) => element?.text == searchCriteria);
  }

  TestElementWrapperCollection searchTextContaining(String searchCriteria) {
    return _search(
      (element) => element?.text?.contains(searchCriteria) == true,
    );
  }

  // Matches a string against a regular expression
  TestElementWrapperCollection searchTextMatch(RegExp searchCriteria) {
    return _search((element) {
      if (element?.text != null) {
        return searchCriteria.hasMatch(element?.text ?? '');
      }
      return false;
    });
  }

  TestElementWrapperCollection searchIcon(IconData searchCriteria) {
    return _search((element) => element?.iconData == searchCriteria);
  }

  TestElementWrapperCollection<W> searchType<W extends Widget>([
    TestElementWrapperCollection<W>? collection,
  ]) {
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
