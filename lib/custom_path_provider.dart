import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPathProvider {
  static const MethodChannel _channel = MethodChannel('custom_path_channel');

  static Future<Directory?> getTemporaryDirectory() async {
    try {
      final String? path = await _channel.invokeMethod('getTempDir');
      return path != null ? Directory(path) : null;
    } on PlatformException catch (e) {
      debugPrint('Failed to get temp dir: ${e.message}');
      return null;
    }
  }

  static Future<Directory?> getApplicationDocumentsDirectory() async {
    try {
      final String? path = await _channel.invokeMethod('getAppDocsDir');
      return path != null ? Directory(path) : null;
    } on PlatformException catch (e) {
      debugPrint('Failed to get app docs dir: ${e.message}');
      return null;
    }
  }
}