import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';

class TestPlatform extends Platform {
  final PlatformType type;
  final Locale locale;
  List<Locale> get locales => <Locale>[locale];

  TestPlatform(
      {this.locale = const Locale('en', 'US'), this.type = PlatformType.test});

  bool get isTest => true;
}

enum PlatformType {
  android,
  fuchsia,
  ios,
  linux,
  macos,
  windows,
  test,
}
