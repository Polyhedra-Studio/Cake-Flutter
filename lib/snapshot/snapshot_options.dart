part of '../cake_flutter.dart';

class SnapshotOptions {
  final bool? _includeSetupWidgets;
  bool get includeSetupWidgets => _includeSetupWidgets ?? false;
  final bool? _createIfMissing;
  bool get createIfMissing => _createIfMissing ?? true;
  final bool? _createCopyIfMismatch;
  bool get createCopyIfMismatch => _createCopyIfMismatch ?? true;
  final String? mismatchDirectory;
  final String? mismatchFileName;
  final bool? _overwriteGolden;
  bool get overwriteGolden => _overwriteGolden ?? false;
  final String? _directory;
  String get directory => _directory ?? 'tests/snapshots';
  final String? fileName;
  final bool? _skipSnapshots;
  bool get skipSnapshots => _skipSnapshots ?? false;
  final String? fontFamily;

  const SnapshotOptions({
    bool? includeSetupWidgets,
    bool? createIfMissing,
    bool? createCopyIfMismatch,
    this.mismatchDirectory,
    this.mismatchFileName,
    bool? overwriteGolden,
    String? directory,
    this.fileName,
    bool? skipSnapshots,
    this.fontFamily,
  })  : _includeSetupWidgets = includeSetupWidgets,
        _createIfMissing = createIfMissing,
        _createCopyIfMismatch = createCopyIfMismatch,
        _overwriteGolden = overwriteGolden,
        _directory = directory,
        _skipSnapshots = skipSnapshots;

  SnapshotOptions.fromParent({
    bool? includeSetupWidgets,
    bool? createIfMissing,
    bool? createCopyIfMismatch,
    String? mismatchDirectory,
    String? mismatchFileName,
    bool? overwriteGolden,
    String? directory,
    String? fileName,
    String? fontFamily,
    // This is intentionally left out on .snapshot()
    bool? skipSnapshots,
    SnapshotOptions? parentOptions,
  })  : _includeSetupWidgets =
            includeSetupWidgets ?? parentOptions?.includeSetupWidgets,
        _createIfMissing = createIfMissing ?? parentOptions?.createIfMissing,
        _createCopyIfMismatch =
            createCopyIfMismatch ?? parentOptions?.createCopyIfMismatch,
        mismatchDirectory =
            mismatchDirectory ?? parentOptions?.mismatchDirectory,
        mismatchFileName = mismatchFileName ?? parentOptions?.mismatchFileName,
        _overwriteGolden = overwriteGolden ?? parentOptions?.overwriteGolden,
        _directory = directory ?? parentOptions?.directory,
        fontFamily = fontFamily ?? parentOptions?.fontFamily,
        fileName = fileName ?? parentOptions?.fileName,
        _skipSnapshots = skipSnapshots ?? parentOptions?.skipSnapshots;

  SnapshotOptions fillWithParentOptions(SnapshotOptions? parentOptions) {
    if (parentOptions == null) {
      return this;
    }
    return SnapshotOptions.fromParent(
      includeSetupWidgets: includeSetupWidgets,
      createIfMissing: createIfMissing,
      createCopyIfMismatch: createCopyIfMismatch,
      mismatchDirectory: mismatchDirectory,
      mismatchFileName: mismatchFileName,
      overwriteGolden: overwriteGolden,
      directory: directory,
      fileName: fileName,
      fontFamily: fontFamily,
      skipSnapshots: skipSnapshots,
      parentOptions: parentOptions,
    );
  }

  bool hasSameOptions(SnapshotOptions? other) {
    if (other == null) {
      return false;
    }
    return includeSetupWidgets == other.includeSetupWidgets &&
        createIfMissing == other.createIfMissing &&
        createCopyIfMismatch == other.createCopyIfMismatch &&
        mismatchDirectory == other.mismatchDirectory &&
        mismatchFileName == other.mismatchFileName &&
        overwriteGolden == other.overwriteGolden &&
        directory == other.directory &&
        fontFamily == other.fontFamily &&
        fileName == other.fileName &&
        skipSnapshots == other.skipSnapshots;
  }
}
