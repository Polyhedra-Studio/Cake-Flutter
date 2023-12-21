import 'package:cake_flutter/test_platform.dart';
import 'package:flutter/widgets.dart';

class CakeMediaQuery {
  MediaQuery _mediaQuery;

  CakeMediaQuery(Widget child, TestPlatform platform)
      : _mediaQuery = MediaQuery(data: MediaQueryData(), child: child);
}
