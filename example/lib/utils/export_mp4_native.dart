import 'dart:async';

import 'package:flutter/services.dart';

class LaminarMp4Exporter {
  static const MethodChannel _channel = MethodChannel('com.laminar/export');

  int _frameCount = 0;
  bool _initialized = false;

  Future<void> initialize({
    required int fps,
    required int width,
    required int height,
    required String qualityName,
  }) async {
    _frameCount = 0;

    await _channel.invokeMethod('initialize', {'fps': fps, 'width': width, 'height': height});

    _initialized = true;
  }

  Future<void> addFrame(Uint8List rgbaBytes) async {
    if (!_initialized) throw Exception('Exporter not initialized');

    // Send the raw bytes over the platform channel.
    // They are received natively and pushed to a background thread to prevent jank.
    await _channel.invokeMethod('addFrame', {'bytes': rgbaBytes});

    _frameCount++;
  }

  Future<String> export(void Function(double) onProgress) async {
    if (!_initialized) throw Exception('Exporter not initialized');
    if (_frameCount == 0) throw Exception('No frames provided');

    onProgress(0.5);

    // Tell the native side to finish muxing and return the file path
    final outputPath = await _channel.invokeMethod<String>('finish');

    if (outputPath == null) {
      throw Exception('Export failed to return a valid path');
    }

    onProgress(1.0);
    _initialized = false;
    return outputPath;
  }

  Future<void> dispose() async {
    _initialized = false;
  }
}
