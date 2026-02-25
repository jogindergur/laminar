import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('window.laminarMuxer')
extension type LaminarMuxer._(JSObject _) implements JSObject {
  external JSPromise initialize(JSNumber width, JSNumber height, JSNumber fps);
  external JSPromise addFrame(JSUint8Array rgbaBytes, JSNumber width, JSNumber height);
  external JSPromise finish(JSString filename);
}

@JS('window.laminarMuxer')
external LaminarMuxer get laminarMuxer;

class LaminarMp4Exporter {
  int _width = 1920;
  int _height = 1080;
  String _qualityName = 'HD';
  int _frameCount = 0;
  bool _initialized = false;

  Future<void> initialize({
    required int fps,
    required int width,
    required int height,
    required String qualityName,
  }) async {
    _width = width;
    _height = height;
    _qualityName = qualityName;
    _frameCount = 0;

    await laminarMuxer.initialize(width.toJS, height.toJS, fps.toJS).toDart;
    _initialized = true;
  }

  Future<void> addFrame(Uint8List rgbaBytes) async {
    if (!_initialized) throw Exception('Exporter not initialized');
    await laminarMuxer.addFrame(rgbaBytes.toJS, _width.toJS, _height.toJS).toDart;
    _frameCount++;
  }

  Future<String> export(void Function(double) onProgress) async {
    if (!_initialized) throw Exception('Exporter not initialized');
    if (_frameCount == 0) throw Exception('No frames provided');

    // In a real scenario we'd stream progress back from JS, but for now
    // the frame encoding inherently takes time, and muxing natively is almost instant.
    onProgress(1.0);

    final filename = 'laminar_export_${_qualityName}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await laminarMuxer.finish(filename.toJS).toDart;

    _initialized = false;
    return 'Web Download Triggered';
  }

  Future<void> dispose() async {
    _initialized = false;
  }
}
