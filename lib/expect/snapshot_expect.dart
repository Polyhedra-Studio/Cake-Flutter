part of '../../cake_flutter.dart';

class SnapshotExpect extends Expect<Snapshot> {
  SnapshotExpect({super.actual, super.expected});

  factory SnapshotExpect.snapshotMatches(Snapshot snapshot) {
    return _SnapshotMatcher(snapshot);
  }

  /// Synonym for [snapshotMatches]
  factory SnapshotExpect.matchesGolden(Snapshot snapshot) {
    return _SnapshotMatcher(snapshot);
  }

  static List<SnapshotExpect> snapshotsMatch(List<Snapshot> snapshots) {
    return snapshots
        .map((snapshot) => SnapshotExpect.snapshotMatches(snapshot))
        .toList();
  }

  factory SnapshotExpect.snapshotIsEqual({
    required Snapshot actual,
    required Snapshot expected,
  }) {
    return _ExpectSnapshotIsEqual(actual: actual, expected: expected);
  }

  factory SnapshotExpect.snapshotIsNotEqual({
    required Snapshot actual,
    required Snapshot notExpected,
  }) {
    return _ExpectSnapshotIsNotEqual(
      actual: actual,
      notExpected: notExpected,
    );
  }
}

class _SnapshotMatcher extends SnapshotExpect {
  final Snapshot snapshot;

  _SnapshotMatcher(this.snapshot);

  @override
  AssertResult run() {
    final bool? result = snapshot.compare();

    if (result == true) {
      return AssertPass();
    } else if (result == null) {
      if (snapshot._snapshotData == null) {
        return AssertNeutral(
          message:
              'Match: No snapshot data to compare against golden file. Either snapshot was called without an await or no data was able to be captured.',
        );
      } else {
        return AssertNeutral(
          message:
              'Match: No golden file found. If this is a new test, please run again.',
        );
      }
    } else {
      return AssertFailure(
        'Match failed: The snapshot data does not match the golden file.',
      );
    }
  }
}

class _ExpectSnapshotIsEqual extends SnapshotExpect {
  final Snapshot actual;
  final Snapshot expected;

  _ExpectSnapshotIsEqual({required this.actual, required this.expected});

  @override
  AssertResult run() {
    if (actual == expected) {
      return AssertPass();
    } else {
      return AssertFailure(
        'SnapshotIsEqual failed: Expected snapshot ${actual.fileName} to match snapshot ${expected.fileName}.',
      );
    }
  }
}

class _ExpectSnapshotIsNotEqual extends SnapshotExpect {
  final Snapshot actual;
  final Snapshot notExpected;

  _ExpectSnapshotIsNotEqual({
    required this.actual,
    required this.notExpected,
  });

  @override
  AssertResult run() {
    if (actual != notExpected) {
      return AssertPass();
    } else {
      return AssertFailure(
        'SnapshotIsNotEqual failed: Expected snapshot ${actual.fileName} to not match snapshot ${notExpected.fileName}.',
      );
    }
  }
}
