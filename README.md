<div align="center">
    <img src="https://github.com/Polyhedra-Studio/Cake-Dart-VS/blob/main/images/cake_logo.png?raw=true" alt="Cake Tester Logo" width="128" />
    <h1>Cake Test Runner for Flutter</h1>
    <a href="https://pub.dev/packages/cake_flutter"><img alt="Pub Version" src="https://img.shields.io/pub/v/cake_flutter" /></a>
    <a href="https://opensource.org/license/mpl-2-0/"><img src="https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg" alt="License: MPL 2.0" /></a>
    <p>The tiniest unit tester, built for Flutter! Need the base package for just Dart? Grab the base <a href="https://pub.dev/packages/cake">Cake</a> package.</p>
    <p>Running this in VS Code? Install the <a href="https://marketplace.visualstudio.com/items?itemName=Polyhedra.cake-dart-vs">Cake VS-Code extension</a> to run tests inside your IDE, snippets, and more.</p>
</div>

### WARNING: BETA
- This package is currently in beta. Documentation is scarce, functionality might break, and bugs abound. Proceed at your own risk.


# Getting started
## Installing

1. Install [Cake](https://pub.dev/packages/cake) test runner globally.

```
dart pub global activate cake
```

2. (Optional) Install the [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=Polyhedra.cake-dart-vs)

3. Add the `cake_flutter` package to your [dev dependencies](https://pub.dev/packages/cake_flutter/install). (This also includes the `cake` package.)
```
flutter pub add dev:cake_flutter
```

4. Include `flutter_test` package in your [dev dependencies](https://pub.dev/packages/cake_flutter/install).
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

## Running
- Cake will search for anything that has .cake.dart for the file name in the directory that it's run in.

### In the Command Line via Cake
In the CLI in the directory that you want to run your tests in:
```
dart run cake
```

You can also [add flags](#flags) to run specific tests or view output from specific tests.

### In the Command Line via Flutter Test
Cake-Flutter is bootstrapped onto the existing Flutter tester, so it's possible to run Cake test with the `flutter test` command. Although if you do keep to the `.cake.dart` naming conventions, you'll have to call each file individually.

In the CLI in the directory that you want to run your tests in:
```
flutter test path/to/your/test.cake.dart
```

### VS Code
- Run or debug tests in the Test Explorer or directly in the files themselves. (See [Marketplace](https://marketplace.visualstudio.com/items?itemName=Polyhedra.cake-dart-vs) page for more details.)

## Writing unit tests
Let's start off with a quick example. This is the Cake equivalent of the [template Flutter project test](https://github.com/flutter/flutter/blob/master/packages/flutter_tools/templates/app_test_widget/test/widget_test.dart.tmpl).

```dart
import 'package:cake_flutter/cake_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  FlutterTestRunner(
    'Counter increments smoke test',
    [
      Test(
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

**For more examples, check out the `/examples/test` folder.**

### Organization
Cake relies on a hierarchy to organize tests. All tests _must_ be wrapped in a TestRunner. From there, you can list Tests directly or further nest them into groups. It's recommended to have one TestRunner per file.

### Stages
Cake encourages developers to write clean, simple, atomic tests by defining separate stages for each test. You might recognize this from the "Arrange-Act-Assert" or "Given-When-Then" style of writing unit tests. Here, you could analogue this to "Setup-Action-Assertions" (with additional teardown if needed).

All stages can be written as asynchronous, if needed.

#### Setup & Teardown
Setup and teardown is inherited from parents to children tests and groups. So you can write your initial setup logic in the root TestRunner, and then run any specific set up later in a group or test to specifically arrange for that functionality being tested on. All setup is run before any action. All teardown is run after all assertions have completed, and will run regardless if any issues occurred during testing.

#### Action
The action stage is meant to highlight the action being taken to test the outcome. This would be something like clicking a button, sending an API call, or running a function. Just remember that only _one_ action can be run during a test. If you find that your action function is large or encompassing a lot of code, that is usually a sign that it needs to broken into multiple tests or into the setup function.

While often need, the action stage is not required. Often unit tests that validate the initial state will skip the action stage.

Action can return a value to be set to the "actual" value that can be later used in assertions.

#### Assertions
Assertions run after the action stage and return a list of [Expects](#expect-matches). That, when applicable, take an expected output and matches it against an actual outcome. There's no limitations on how many assertions you can run. By default, Cake will ignore the rest of the assertions after the first one fails. This can be turned off in [Options](#options).

### Context
Context is how information can be passed from stage to stage and is an inheritable object that is passed from parent to children. This is passed as an argument on each stage. 

### Flutter Context 
Unlike the base Dart Cake, Flutter Cake has it's own Flutter context that behaves like a wrapper around the flutter_test package. 

#### WidgetTester
You can access the flutter_test WidgetTester on the `tester` property of the Flutter Context. Ideally you shouldn't need to, but it's there if you're trying to migrate tests to Cake or as a workaround.

#### Search
Like `find` in test runner, Cake Tester has it's own similar search feature that crawls and indexes the widget tree of your test.

Valid search criteria:
- By Key
- By Icon
- By Text
- By widget type

#### Indexing
Searching requires a bit of processing to index, so you must manually call test.index() first. Once index you can call test.search to search widgets. You can add indexing options to only index certain widgets for better search performance or enable debugging options to print to the console. Remember to turn off any debugging flags before commit code.

## Expect Matches
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

## Flags

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