part of '../../cake_flutter.dart';

class FlutterContextController {
  static final FlutterContextController _instance =
      FlutterContextController._();
  factory FlutterContextController() => _instance;
  FlutterContextController._();

  static bool _parentContextHasInitialized = false;
  static Completer<void>? _onComplete;
  static Completer<void>? get onComplete {
    return _onComplete;
  }

  static FutureOr<FlutterContext> flutterContextBuilder({
    required FlutterTestOptions? options,
    required String title,
  }) {
    if (!_parentContextHasInitialized) {
      _parentContextHasInitialized = true;
      final Completer<FlutterContext> completer = Completer<FlutterContext>();
      testWidgets(
        title,
        (widgetTester) async {
          widgetTester.runAsync(() async {
            final Completer<void> cakeTestsComplete = Completer<void>();

            _onComplete = cakeTestsComplete;
            completer.complete(
              FlutterContext._(options: options, tester: widgetTester),
            );

            // Signal to Flutter tester that Cake has completed its tests and
            // Flutter tester may now begin teardown.
            await cakeTestsComplete.future;

            TestAsyncUtils.verifyAllScopesClosed();
          });
        },
      );
      return completer.future;
    } else {
      return FlutterContext._child(options: options);
    }
  }
}
