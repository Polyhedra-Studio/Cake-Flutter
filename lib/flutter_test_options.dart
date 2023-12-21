import 'package:cake_flutter/cake_flutter.dart';
import 'package:cake_flutter/test_platform.dart';
import 'package:flutter/widgets.dart';

class FlutterTestOptions extends TestOptions {
  final TestPlatform? platform;
  final MediaQueryData? mediaQueryData;

  const FlutterTestOptions({
    this.platform,
    this.mediaQueryData,
    super.failOnFirstExpect,
  });
}
