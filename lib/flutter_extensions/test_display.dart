import 'dart:ui';

import 'package:flutter/widgets.dart';

class TestDisplay implements Display {
  final MediaQueryData _data;
  TestDisplay(this._data);

  @override
  double get devicePixelRatio => _data.devicePixelRatio;

  @override
  int get id => -1;

  @override
  double get refreshRate => 60.0;

  @override
  Size get size => _data.size;
}
