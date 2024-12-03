part of '../cake_flutter.dart';

class Snapshot {
  final SnapshotOptions options;
  final String fileName;
  Uint8List? _snapshotData;
  Uint8List? _goldenData;
  Uint8List? get snapshotData => _snapshotData;
  Uint8List? get goldenData => _goldenData;

  Snapshot({
    required this.options,
    required String testName,
  }) : fileName = options.fileName != null
            ? _sanitizeFileName(options.fileName!)
            : _sanitizeFileName(testName, autogenerated: true);

  Future<void> create(
    RenderRepaintBoundary boundary,
  ) async {
    // Create data for snapshot
    final image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ImageByteFormat.png);
    _snapshotData = byteData!.buffer.asUint8List();

    // Find directory
    final Directory directory =
        await Directory(options.directory).create(recursive: true);
    final file = File('${directory.path}/$fileName.png');

    // Retrieve or create golden data, depending on settings
    if (file.existsSync()) {
      if (options.overwriteGolden) {
        await file.writeAsBytes(_snapshotData!);
        _goldenData = null;
      } else {
        _goldenData = await file.readAsBytes();
      }

      if (options.createCopyIfMismatch && compare() == false) {
        Directory copyDirectory = directory;
        if (options.mismatchDirectory != null) {
          copyDirectory = await Directory(options.mismatchDirectory!)
              .create(recursive: true);
        }
        final String copyFileName = '${fileName}_mismatch';
        final File copyFile = File('${copyDirectory.path}/$copyFileName.png');
        await copyFile.writeAsBytes(_snapshotData!);
      }
    } else {
      _goldenData = null;

      if (options.createIfMissing) {
        await file.writeAsBytes(_snapshotData!);
      }
    }
  }

  /// Returns null if either the snapshot or golden data is null, otherwise
  /// returns true if the snapshot and golden data are the same.
  bool? compare() {
    if (_goldenData == null || _snapshotData == null) {
      return null;
    }

    return listEquals(_goldenData, _snapshotData);
  }

  /// We only care about the snapshot data for equality comparisons.
  @override
  bool operator ==(Object other) =>
      other is Snapshot && other.snapshotData == snapshotData;

  @override
  int get hashCode => snapshotData.hashCode;

  static String _sanitizeFileName(String fileName, {bool? autogenerated}) {
    // Remove leading and trailing spaces
    fileName = fileName.trim();

    // Limit length to max 255 characters
    if (fileName.length > 255) {
      fileName = fileName.substring(0, 255);
    }

    // Remove invalid characters
    fileName = fileName.replaceAll(r'[\/\\:*?"<>|]', '');

    if (autogenerated == true) {
      // Convert to lowercase
      fileName = fileName.toLowerCase();

      // Replace spaces with underscores
      fileName = fileName.replaceAll(' ', '_');

      // Remove commas and periods and other punctuation, while still
      // allowing for non-ascii characters
      fileName = fileName.replaceAll(RegExp(r'[^\w\u00C0-\u017F]+'), '');
    }

    if (fileName.isEmpty) {
      fileName = 'snapshot';
    }

    return fileName;
  }
}