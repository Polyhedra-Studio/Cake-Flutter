import 'package:cake_flutter/widget_tree.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CakeElement<T extends Element> extends Element with CakeElementMixin {
  final T _element;
  CakeElement(
    this._element,
    super.widget, {
    required WidgetTreeBuilder onBuild,
  }) {
    this.onBuild = onBuild;
  }

  @override
  bool get debugDoingBuild => _element.debugDoingBuild;
}

class CakeStatelessElement extends StatelessElement with CakeElementMixin {
  final StatelessElement _element;
  CakeStatelessElement(
    this._element,
    super.widget, {
    required WidgetTreeBuilder onBuild,
  }) {
    this.onBuild = onBuild;
  }

  @override
  bool get debugDoingBuild => _element.debugDoingBuild;
}

mixin CakeElementMixin on Element {
  WidgetTreeBuilder _onBuild = (nodeWidget) => {};

  set onBuild(WidgetTreeBuilder onBuild) {
    _onBuild = onBuild;
  }

  @override
  CakeElement inflateWidget(Widget newWidget, Object? newSlot) {
    final Element newElement = super.inflateWidget(newWidget, newSlot);
    _onBuild(newElement);
    return CakeElement(
      newElement,
      newElement.widget,
      onBuild: _onBuild,
    );
  }
}
