import 'package:cake_flutter/cake_flutter.dart';
import 'package:cake_flutter/flutter_context.dart';
import 'package:cake_flutter/flutter_test_options.dart';

/// testWidgets('MyWidget', (WidgetTester tester) async {
///   await tester.pumpWidget(MyWidget());
///   await tester.tap(find.text('Save'));
///   await tester.pump(); // allow the application to handle
///   await tester.pump(const Duration(seconds: 1)); // skip past the animation
///   expect(find.text('Success'), findsOneWidget);
/// });

class FlutterTestRunner extends TestRunner<FlutterContext> {
  FlutterTestRunner(
    super._title,
    super.children, {
    FlutterTestOptions? options,
  }) : super(
          contextBuilder: () => FlutterContext(options),
          options: options,
        );

  FlutterTestRunner.skip(
    super._title,
    super.children, {
    FlutterTestOptions? options,
  }) : super.skip(
          contextBuilder: () => FlutterContext(options),
          options: options,
        );
}
