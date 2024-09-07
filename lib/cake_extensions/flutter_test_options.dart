part of '../../cake_flutter.dart';

class FlutterTestOptions extends TestOptions {
  final bool? failOnFirstExpect;
  final SnapshotOptions? snapshotOptions;
  final SetupSettings? setupSettings;

  const FlutterTestOptions({
    this.failOnFirstExpect,
    this.snapshotOptions,
    this.setupSettings,
  }) : super(failOnFirstExpect: failOnFirstExpect);

  FlutterTestOptions mapParentFlutterOptions(FlutterTestOptions? parent) {
    if (parent == null) return this;
    return FlutterTestOptions(
      failOnFirstExpect: failOnFirstExpect ?? parent.failOnFirstExpect,
      snapshotOptions: snapshotOptions ?? parent.snapshotOptions,
      setupSettings: setupSettings ?? parent.setupSettings,
    );
  }
}
