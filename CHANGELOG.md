## 0.7.1 (2025-01-06)
- [PKG] Removed dependency on flutter_tools

## 0.7.0 (2024-07-25)
- [ADD][Snap] Added Snapshot testing. The .snapshot() function can be called any time on the context object to take a snapshot of the current widget. It can also be called on a search collection to take a snapshot of specific widgets. Snapshots are kept on the context.snapshots collection for easy testing.
- [ADD][Expect] Added .snapshotMatches(), .snapshotsMatch(), and .matchesGolden() to compare snapshots against existing versions.
- [ADD][Expect] Added .snapshotIsEqual() and .snapshotIsNotEqual() to compare against two snapshots taken. Useful for before and after states.
- [MOD][Setup] SetupSettings can now be inherited.
- [ADD][Setup] Added .setSurfaceSize() and surfaceSize parameter to SetupSettings and setApp. This functionality allows for the screen size to be changed dynamically.
- [ADD][Setup] Added includeNavigationMock and navigationMocks parameter to SetupSettings and setApp. This allows for navigation to be observable for ensuring when a navigation call is made.ß
- [PKG] Updated Cake to 6.2.0 to include mocks.
- [MOD][Meta] File organization
- [ADD][Errors] Added CakeFlutterError, which has special formatting for displaying error messages, short description of where the error occurred, and (hopefully) helpful hints on how to proceed when the error occurs.

Here's an example of the new error style:
```
 - CakeFlutterError: --------------------------------------------------------------
|                                                                                  |
| Desc: _ElevatedButtonWithIcon [String <'ImportMenuWidget - Button:               |
|       uploadOrders'>] at Offset(320.9, 318.0) was not hit.                       |
|   On: search.key([String <'ImportMenuWidget - Button: uploadOrders'>]).tap()     |
| Hint: The widget is could be off-screen, or another widget is obscuring it, or   |
|       the widget cannot receive pointer events.                                  |
|                                                                                  |
|       If this action is intentional, mute this message with the "warnIfMissed"   |
|       flag.                                                                      |
|                                                                                  |
 - Stacktrace: --------------------------------------------------------------------
# 0     [Stacktrace information...]
 ```

## 0.6.0 (2024-07-20)
- [BREAKING][Index] IndexOptions are now expanded in the test.index() parameters.
- [BREAKING][Search] By default, search will only index the widget being called by setApp. To revert to the old behavior of indexing the entire widget tree, turn on includeSetupWidgets in IndexOptions. This might be needed if you are searching for something that fires off of the scaffold widget, such as dialogs and snack bars.
- [MOD][Setup] setApp now sets the child of the RootWidget class and maintains scaffolding data between tests to help with performance and consistency between tests. 
- [FIX][Setup] setApp can now be safely be called between sibling tests without having to worry about states being shared.
- [ADD][Context] Added test.clear() function, which will completely clear out the root widget. In theory, this shouldn't be needed since setApp should be fully replacing the old child, but this can help if the application is in a stuck state.
- [ADD][Context] Added a test.next() function to go with test.forward(). This would be the same as calling pumpAndSettle, which waits until all animations and frames are done loading.
- [PKG] Updated to Cake 6.1.0, which includes new meta information about the current test attached to the context.
- [ADD][Debug] Added the debugContents option, which will print out any keys and text in a similar nested format to debugTree. For clarity, if both debugContents and debugTree is on, debugContents will print after debugTree. DebugContents will also respect the same debug filters debugTree uses. This functionality may be expanded in the future to other widgets.
- [ADD][Search] Added .keyText() to search for the string contents of a key. Good for when you do not have a direct reference to the key available.
- [ADD][Setup] Added index option to setApp() automatically index without any options after setting the root app. Meant to be used for shorthand for simple tests, but is turned off by default.
- [ADD][Setup] Added indexOptions to setApp() to automatically index with given options after setting the root app. Meant to be used for shorthand. Ignores index if set.

## 0.5.0 (2024-05-24)
- [ADD][Setup] Added options to setApp that includes Localization data

## 0.4.0 (2023-12-30)
- [ADD][Search] Added tap() action as a shortcut for .first.tap()
- [ADD][Expect] Added expects: searchHasNone, searchHasOne, searchHasSome that searches for a number of widgets that works similar to the find matchers.
- [MOD][Search] Search can now be run without indexing first - it will run with full search tree, which while not ideal, might help with quick and dirty tests.
- [ADD][Search] Added indexing by Key.
- [ADD] Error widgets that appear will not be reported when indexed. This can be ignored through IndexOptions.
- [ADD][Setup] Added options to setApp that includes: Scaffold, MaterialApp, Directionality, and ThemeData.
- [ADD][Search] Added reference to widget when searching a group by type

## 0.3.4 (2023-12-29)
- [PKG] Updated Cake to 6.0.1, enabling filtering flags to be used in the CLI.

## 0.3.3 (2023-12-28)
- [FIX][Search] Fixed children reference for Search not showing up properly when fetched through asType.

## 0.3.2 (2023-12-27)
- [META] Added example folder
- [META] Updated README.md
- [META] Cleaned up some testing package files

## 0.3.1 (2023-12-26)
- [FIX] Fixed flutter_tester hanging after tests are complete.
- [MOD] Included IndexOptions to main library.
- [ADD] Added TestAsyncUtils.guard() to all current async operations to protect against un-awaited calls. This should make it work similar to how flutter_test works.

## 0.3.0 (2023-12-26)
- [ADD] Added IndexOptions to search. IndexOptions currently allows for only certain widget types to be indexed for better search performance and shows debugging options for printing to the console.
- [ADD][Search] Search will now throw an error if an un-indexed type is searched.

## 0.2.0 (2023-12-25)
- [ADD][Expect] Added isWidgetType to match against a TestElementWrapper.
- [ADD] Added a reference to children, if any, for each TestElementWrapper.
- [ADD][Search] Added key to allow searching by key. This will return a single TestElementWrapper rather than a collection.

## 0.1.0
- Scrubbed, ignore this tag.

## 0.0.1 (2023-12-24)

- Initial release. CLI is still work in progress, but running files individually with `flutter test [file]` should work. ~~(Note: there's a bug where it hangs after finishing. Press `ctrl+c` to close.)~~ This was fixed with 0.3.1.