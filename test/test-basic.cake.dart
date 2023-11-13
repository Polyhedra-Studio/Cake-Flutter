import 'package:cake_flutter/cake_flutter.dart';

void main() {
  TestRunnerDefault('Test Runner - Basic', [
    Group('Group - Basic', [
      Test(
        'True should be true',
        assertions: (test) => [Expect.isTrue(true)],
      ),
    ]),
  ]);
}
