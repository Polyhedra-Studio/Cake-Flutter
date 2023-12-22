import 'dart:async';

import 'package:cake_flutter/cake_flutter.dart';
import 'package:cake_flutter/flutter_extensions/cake_binding.dart';
import 'package:cake_flutter/flutter_test_options.dart';
import 'package:cake_flutter/search.dart';
import 'package:cake_flutter/widget_tree.dart';
import 'package:flutter/widgets.dart';

class FlutterContext extends Context {
  Search? _search;
  Search get search {
    assert(
      _search != null,
      'App or Widget not initialized or is not ready yet. Call setApp() in an async first.',
    );

    return _search!;
  }

  CakeBinding? _binding;
  CakeBinding get binding => _binding ??= CakeBinding(_options);
  final FlutterTestOptions? _options;

  FlutterContext(this._options);

  @override
  void copyExtraParams(Context contextToCopy) {
    if (contextToCopy is FlutterContext) {
      _binding = contextToCopy.binding;
      _search = contextToCopy._search;
    }
  }

  Future<void> setApp(Widget app) async {
    final WidgetTreeRoot tree = WidgetTreeRoot(app);
    await tree.createRoot(binding);
    _search = Search(tree);
    return forward(duration: Duration(seconds: 1));
  }

  Future<void> forward({Duration duration = Duration.zero}) async {
    return binding.forward(duration: duration);
  }

  void pumpWidget() {
    return;
  }
}
