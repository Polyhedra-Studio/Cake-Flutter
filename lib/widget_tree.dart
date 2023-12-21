// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:cake_flutter/flutter_extensions/cake_binding.dart';
import 'package:cake_flutter/flutter_extensions/cake_element.dart';
import 'package:cake_flutter/flutter_extensions/test_view_widget.dart';
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
  WidgetTreeNode(this.nodeElement);

  void create() {
    // This item should already be built, find it within the existing tree
    _widgetWrapper = TestElementWrapper(nodeElement);
    _findChildren(nodeElement);
  }
}

abstract class WidgetTree {
  TestElementWrapper? _widgetWrapper;
  final List<WidgetTree> _children = [];

  WidgetTree();

  TestElementWrapperCollection searchText(
    String searchCriteria, [
    TestElementWrapperCollection? collection,
  ]) {
    collection ??= TestElementWrapperCollection();

    if (_widgetWrapper?.text == searchCriteria) {
      collection.add(_widgetWrapper!);
    }
    for (var element in _children) {
      element.searchText(searchCriteria, collection);
    }

    return collection;
  }

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
      final WidgetTreeNode tree = WidgetTreeNode(child);
      tree.create();
      _children.add(tree);
    }
  }
}
