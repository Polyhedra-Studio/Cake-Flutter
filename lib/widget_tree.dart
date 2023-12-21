// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:cake_flutter/flutter_extensions/cake_binding.dart';
import 'package:cake_flutter/test_element_wrapper.dart';
import 'package:flutter/material.dart';

class WidgetTreeRoot extends WidgetTree {
  final Widget rootWidget;
  WidgetTreeRoot(this.rootWidget);

  Future<void> createRoot(CakeBinding binding) async {
    await binding.setRoot(
      rootWidget,
      onBuild: (Element nodeElement) {
        _add(nodeElement);
      },
    );
  }
}

typedef WidgetTreeBuilder = void Function(Element nodeElement);

class WidgetTreeNode extends WidgetTree {
  final Element nodeElement;
  final Widget widget;
  WidgetTreeNode(this.nodeElement, this.widget);

  void create() {
    // This item should already be built, find it within the existing tree
    _elementWrapper = TestElementWrapper(nodeElement);
    _findChildren(nodeElement);
  }
}

abstract class WidgetTree {
  TestElementWrapper? _elementWrapper;
  final List<WidgetTree> _children = [];

  WidgetTree();

  void _findChildren(Element? element) {
    print('Finding children for ${element?.widget.runtimeType}');

    element?.visitChildren(
      (element) {
        _add(element);
      },
    );
  }

  void _add(Element? child) {
    if (child != null) {
      final WidgetTreeNode tree = WidgetTreeNode(child, child.widget);
      tree.create();
      _children.add(tree);
    }
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
