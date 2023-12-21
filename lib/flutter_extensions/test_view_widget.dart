import 'package:cake_flutter/flutter_extensions/cake_element.dart';
import 'package:cake_flutter/flutter_extensions/test_flutter_view.dart';
import 'package:cake_flutter/widget_tree.dart';
import 'package:flutter/widgets.dart';

class TestView extends View {
  final TestFlutterView flutterView;
  final WidgetTreeBuilder onBuild;

  TestView({
    required this.flutterView,
    required super.child,
    required this.onBuild,
  }) : super(view: flutterView);

  @override
  StatelessElement createElement() {
    return CakeStatelessElement(super.createElement(), this, onBuild: onBuild);
  }
}
