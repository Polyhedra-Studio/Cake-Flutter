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
    super.setup,
    super.teardown,
    FlutterTestOptions? options,
  }) : super(
          contextBuilder: () async {
            final FlutterContext flutterContext =
                await FlutterContextController.flutterContextBuilder(
              options: options,
              title: _title,
            );
            return flutterContext;
          },
          options: options,
          onComplete: (String _) =>
              FlutterContextController.onComplete?.complete(),
        );

  FlutterTestRunner.skip(
    super._title,
    super.children, {
    super.setup,
    super.teardown,
    FlutterTestOptions? options,
  }) : super.skip(
          contextBuilder: () async =>
              await FlutterContextController.flutterContextBuilder(
            options: options,
            title: _title,
          ),
          options: options,
          onComplete: (String _) =>
              FlutterContextController.onComplete?.complete(),
        );
}
