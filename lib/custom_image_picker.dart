import 'dart:io';
import 'package:flutter/services.dart';

enum ImageSource { gallery, camera }

class CustomImagePicker {
  static const MethodChannel _channel = MethodChannel('custom_picker_channel');

  static Future<File?> pickImage({required ImageSource source}) async {
    try {
      final String sourceString = source == ImageSource.gallery
          ? 'gallery'
          : 'camera';
      final String? path = await _channel.invokeMethod('pickImage', {
        'source': sourceString,
      });

      if (path != null && path.isNotEmpty) {
        return File(path);
      }
      return null;
    } on PlatformException catch (e) {
      print('Failed to pick image: ${e.message}');
      return null;
    }
  }
}
