# Cake
The tiniest unit tester, built for Flutter
(Want just Dart? try [Cake for Dart](https://github.com/Polyhedra-Studio/Cake))

# WARNING: BETA
- This package is currently in beta. Documentation is scarce, functionality might break, and bugs abound. Proceed at your own risk.

# How to write unit tests
- Cake will search for anything that has .cake.test for the file name in the directory that it's run in
- Example of how to write unit tests. This is the Cake equivalent of the [template Flutter project test](https://github.com/flutter/flutter/blob/master/packages/flutter_tools/templates/app_test_widget/test/widget_test.dart.tmpl).
```dart
import 'package:cake_flutter/cake_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  FlutterTestRunner(
    'Counter increments smoke test',
    [
      Test.skip(
        'Counter should start at zero',
        action: (test) => test.index(),
        assertions: (test) => [
          Expect.equals(actual: test.search.text('0').length, expected: 1),
          Expect.equals(actual: test.search.text('1').length, expected: 0),
        ],
      ),
      Test(
        'Counter should increment when + is tapped',
        action: (test) async {
          test.index();
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
    },
  );
}
```


# Expect Matches
Generic
  - equals
  - isEqual *
  - isNotEqual
  - isNull
  - isNotNull
  - isType **
  - isTrue
  - isFalse

* equals and isEqual can be used interchangeably.
** isType will need a generic defined or else it will always pass as true as it thinks the type is `dynamic`.

Flutter-specific
  - isWidgetType *
  - findMatch
  - findsOneWidget
  - findsNothing
  - findsWidgets
  - findsNWidgets
  - findsAtLeastNWidgets

* isWidgetType will need a generic defined or else it will always pass as true as it thinks the type is `Widget`.

# Search
Like `find` in test runner, Cake Tester has it's own similar search feature that crawls and indexes the widget tree of your test. Searching requires a bit of processing to index, so you must manually call test.index() first. Once index you can call test.search to search widgets.

Valid search criteria:
- By Key
- By Icon
- By Text
- By widget type

# How to run the test runner
- Cake-Flutter is bootstrapped onto the existing Flutter tester. Unlike Cake-Dart which can be run independently, these tests need to be run through the native test commands. If you use the `.cake.dart` extension, you will have to run each file separately like so `flutter test widget.cake.dart`

## Flags - Not yet implemented.

### File name filter
- `-f [fileName]`
  - Filters tests based off of file name
  - EX: `dart run cake -f foo` will test 'test-foo.cake.dart'

### Verbose mode
- `-v` or `--verbose`
  - Displays full output of summary and tests run

### Test Filter
- `-t [testFilter]`, `--tt [testFilter]`, `--tte [testName]`,  `--tg [groupFilter]`, `--tge [groupName]`, `--tr [testRunnerFilter]`, `--tre [testRunnerName]`
  - All of these do similar things, which filters based off of title of the item. You can also use certain tags to run only a group, test runner, or a specific test.
  - Note - search is case-sensitive.
  - Examples: 
    - `-t` **General search:** `dart run cake -t foo` - Run all tests, groups, and runners with "foo" in the title
    - `--tt` **Test search** `dart run cake --tt "cool test"` - Run all tests with the phrase "cool test" in the title
    - `--tte` **Test search, exact:** `dart run cake --tte "should only run when this one specific thing happens"` - Runs only the test that matches the phrase exactly.
    - `--tg` **Group search** `dart run cake --tg bar` - Run all groups matching "bar" in the title
    - `--tge` **Group search, exact:** `dart run cake --tge "API Endpoints" - Runs all groups _exactly_ matching the phrase "API Endpoints"
    - `--tr` **Test Runner search:** `dart run cake --tr "Models" - Runs all test runners with "Models" in the title
    - `--tre` **Test Runner search, exact:** `dart run cake --tre "Models - User"` - Runs test runners that _exactly_ match the phrase "Models - User" 

### Interactive mode
- `-i`
  - Allows for repeatedly running tests. You can also use the test filters similar to non-interactive mode's syntax.