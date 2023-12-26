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

- Initial release. CLI is still work in progress, but running files individually with `flutter test [file]` should work. (Note: there's a bug where it hangs after finishing. Press `ctrl+c` to close.)