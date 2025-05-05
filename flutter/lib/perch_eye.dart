import 'dart:async';
import 'package:flutter/services.dart';

class PerchEye {
  static const MethodChannel _channel =
      MethodChannel('perch_eye_method_channel');

  static Future<double> compareFaces(
      String base64_1, String base64_2) async {
    final double sim =
        await _channel.invokeMethod('compareFaces', {'img1': base64_1, 'img2': base64_2});
    return sim;
  }
}