part of '../../cake_flutter.dart';

mixin TestElementActions {
  Future<void> tap({bool warnIfMissed = true, bool warnIfInvalid = true});
  Future<void> focus({bool warnIfInvalid = true});
  Future<void> enterText(String text, {bool warnIfInvalid = true});
  Future<void> dismiss({bool warnIfInvalid = true});
  Future<void> swipe(
    SwipeDirection direction, {
    Duration duration = Duration.zero,
    bool warnIfInvalid = true,
  });
  Future<void> swipeCustom({
    required Offset start,
    required Offset end,
    Duration duration = Duration.zero,
    bool warnIfInvalid = true,
  });

  // This should largely mirror flutter_context.snapshot()
  Future<Snapshot?> snapshot({
    bool? includeSetupWidgets,
    bool? createIfMissing,
    bool? createCopyIfMismatch,
    String? mismatchDirectory,
    String? mismatchFileName,
    bool? overwriteGolden,
    String? directory,
    String? fileName,
    String? fontFamily,
    Widget? snapshotWidget,
    SetupSettings? snapshotWidgetSetup,
    bool warnIfInvalid = true,
  });

  bool hasChildOfType<T extends Widget>();
}

enum SwipeDirection { left, right, up, down }
