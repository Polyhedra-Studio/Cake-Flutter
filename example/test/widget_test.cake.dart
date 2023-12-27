import 'package:cake_flutter/cake_flutter.dart';
import 'package:flutter/material.dart';

import 'package:cake_flutter_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

/// This is to demonstrate that you can also use the native Flutter test
/// functionality while using Cake-style tests.
void main() {
  FlutterTestRunner(
    'Counter increments smoke test',
    [
      Test(
        'Counter should start at zero',
        assertions: (test) => [
          FlutterExpect.findsOneWidget(find.text('0')),
          FlutterExpect.findsNothing(find.text('1')),
        ],
      ),
      Test(
        'Counter should increment when + is tapped',
        action: (test) async {
          await test.tester.tap(find.byIcon(Icons.add));
          await test.forward();
        },
        assertions: (test) => [
          FlutterExpect.findMatch(find: find.text('0'), match: findsNothing),
          FlutterExpect.findMatch(find: find.text('1'), match: findsOneWidget),
        ],
      ),
    ],
    setup: (test) async {
      await test.setApp(const MyApp());
    },
  );
}
