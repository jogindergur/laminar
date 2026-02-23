import 'dart:typed_data';

class LaminarMp4Exporter {
  Future<void> initialize({
    required int fps,
    required int width,
    required int height,
    required String qualityName,
  }) async {}

  Future<void> addFrame(Uint8List pngBytes) async {}

  Future<String> export(void Function(double) onProgress) async {
    throw UnsupportedError('Cannot export MP4 on this platform');
  }

  Future<void> dispose() async {}
}
