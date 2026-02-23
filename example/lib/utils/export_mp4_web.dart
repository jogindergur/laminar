import 'dart:js_interop';

import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class LaminarMp4Exporter {
  final List<Uint8List> _frames = [];
  int _fps = 30;
  String _qualityName = 'HD';

  Future<void> initialize({
    required int fps,
    required int width,
    required int height,
    required String qualityName,
  }) async {
    _fps = fps;
    _qualityName = qualityName;
    _frames.clear();
  }

  Future<void> addFrame(Uint8List pngBytes) async {
    _frames.add(pngBytes);
  }

  Future<String> export(void Function(double) onProgress) async {
    if (_frames.isEmpty) throw Exception('No frames provided');

    final ffmpeg = createFFmpeg(
      CreateFFmpegParam(
        log: true,
        corePath: 'https://unpkg.com/@ffmpeg/core-st@0.11.1/dist/ffmpeg-core.js',
        mainName: 'main',
      ),
    );

    ffmpeg.setProgress((ProgressParam progress) {
      onProgress(0.5 + (progress.ratio * 0.5));
    });

    ffmpeg.setLogger((LoggerParam logger) {
      debugPrint('FFmpeg Log [${logger.type}]: ${logger.message}');
    });

    await ffmpeg.load();

    for (int i = 0; i < _frames.length; i++) {
      final fileName = 'frame_${i.toString().padLeft(4, '0')}.png';
      ffmpeg.writeFile(fileName, _frames[i]);
      if (i % 10 == 0) {
        onProgress((i / _frames.length) * 0.5);
      }
    }

    await ffmpeg.run([
      '-framerate',
      _fps.toString(),
      '-i',
      'frame_%04d.png',
      '-vf',
      'scale=trunc(iw/2)*2:trunc(ih/2)*2',
      '-c:v',
      'libx264',
      '-preset',
      'ultrafast',
      '-profile:v',
      'high',
      '-level:v',
      '5.1',
      '-crf',
      '18',
      '-color_primaries',
      'bt709',
      '-color_trc',
      'bt709',
      '-colorspace',
      'bt709',
      '-pix_fmt',
      'yuv420p',
      'output.mp4',
    ]);

    final Uint8List outData = ffmpeg.readFile('output.mp4');

    final jsArray = outData.toJS;
    final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'video/mp4'));
    final url = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = 'laminar_export_${_qualityName}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    web.document.body?.appendChild(anchor);
    anchor.click();
    web.document.body?.removeChild(anchor);
    web.URL.revokeObjectURL(url);

    return 'Web Download Triggered';
  }

  Future<void> dispose() async {
    _frames.clear();
  }
}
