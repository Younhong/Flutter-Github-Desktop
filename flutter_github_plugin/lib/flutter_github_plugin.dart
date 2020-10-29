
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterGithubPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_github_plugin');

  static Future<void> activate() async {
    await _channel.invokeMethod('activate');
  }
}
