import 'package:cake_flutter/flutter_extensions/cake_element.dart';
import 'package:cake_flutter/widget_tree.dart';
import 'package:flutter/src/rendering/object.dart';
import 'package:flutter/widgets.dart';

class CakeRenderObjectToWidgetAdapter<T extends RenderObject>
    extends RenderObjectToWidgetAdapter<T> {
  final WidgetTreeBuilder onBuild;

  // Reason: Key is created in super object without option to be overridden.
  // ignore: use_key_in_widget_constructors
  CakeRenderObjectToWidgetAdapter({
    super.child,
    required super.container,
    super.debugShortDescription,
    required this.onBuild,
  });

  // Mirrors attachToRenderTree
  CakeRenderObjectToWidgetElement<T> attachToTestRenderTree(
    BuildOwner owner, [
    CakeRenderObjectToWidgetElement<T>? element,
  ]) {
    if (element == null) {
      owner.lockState(() {
        element = createTestElement();
        assert(element != null);
        element!.assignOwner(owner);
      });
      owner.buildScope(element!, () {
        element!.mount(null, null);
      });
    }
    return element!;
  }

  CakeRenderObjectToWidgetElement<T> createTestElement() {
    return CakeRenderObjectToWidgetElement<T>(
      this,
      onBuild: onBuild,
    );
  }
}

class CakeRenderObjectToWidgetElement<T extends RenderObject>
    extends RenderObjectToWidgetElement<T> {
  final WidgetTreeBuilder onBuild;

  CakeRenderObjectToWidgetElement(super.widget, {required this.onBuild});

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
  }

  @override
  CakeElement? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    final Element? element = super.updateChild(child, newWidget, newSlot);
    return element == null
        ? null
        : CakeElement(element, element.widget, onBuild: onBuild);
  }
}
