import 'package:cake_flutter/cake_flutter.dart';
import 'package:cake_flutter_example/main.dart';
import 'package:flutter/services.dart';

void main() {
  FlutterTestRunner(
    'Counter Snapshots',
    [
      Test(
        'Counter should start at zero',
        action: (test) async {
          test['initial_state'] =
              await test.snapshot(fileName: 'initial_state');
        },
        assertions: (test) => [
          Expect.equals(
            actual: test.search.textIncludes('').length,
            expected: 3,
          ),
          SnapshotExpect.snapshotMatches(test.snapshots.first),
        ],
      ),
      Test(
        'Can take a snapshot of multiple widgets',
        action: (test) async {
          await test.next();
          await test.search.textIncludes('').snapshot(
                fileName: 'multiple_widgets',
                // Because we're taking a snapshot of only text widgets and not
                // it's parent scaffold, we need to specify the text direction.
                snapshotWidgetSetup:
                    const SetupSettings(textDirection: TextDirection.ltr),
              );
        },
        assertions: (test) => [
          // Note that calling a snapshot of a collection will return just
          // one snapshot. This is just here to show different ways to check
          // snapshots.
          ...SnapshotExpect.snapshotsMatch(test.snapshots),
        ],
      ),
    ],
    setup: (test) async {
      // Set up a custom font for the test
      final fontData = rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final fontLoader = FontLoader('Roboto')..addFont(fontData);
      await fontLoader.load();

      await test.setApp(const MyApp());
      test.index(
        debugTypeFilter: IndexOptions.defaultSearchTypes,
        indexTypes: IndexOptions.defaultSearchTypes,
      );
    },
    options: const FlutterTestOptions(
      snapshotOptions: SnapshotOptions(
        directory: 'test/snapshots',
        fontFamily: 'Roboto',
      ),
    ),
  );
}
