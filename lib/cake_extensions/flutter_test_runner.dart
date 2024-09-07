part of '../../cake_flutter.dart';

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
