import 'package:cake_flutter/cake_flutter.dart';
import 'package:cake_flutter_example/main.dart';
import 'package:flutter/material.dart';

void main() {
  FlutterTestRunner(
    'Counter increments smoke test',
    [
      Test(
        'Counter should start at zero',
        assertions: (test) => [
          Expect.equals(actual: test.search.text('0').length, expected: 1),
          Expect.equals(actual: test.search.text('1').length, expected: 0),
        ],
      ),
      Test(
        'Counter should increment when + is tapped',
        action: (test) async {
          await test.search.icon(Icons.add).first.tap();
          await test.forward();
          test.index();
        },
        assertions: (test) => [
          Expect.equals(actual: test.search.text('0').length, expected: 0),
          Expect.equals(actual: test.search.text('1').length, expected: 1),
        ],
      ),
    ],
    setup: (test) async {
      await test.setApp(const MyApp());
      test.index(
        debugTypeFilter: IndexOptions.defaultSearchTypes,
        indexTypes: IndexOptions.defaultSearchTypes,
      );
    },
    options: const FlutterTestOptions(
      failOnFirstExpect: false,
    ),
  );
}
