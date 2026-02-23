import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Writes PNG bytes to disk over a background Isolate.
/// Keeps heavy 4K I/O operations strictly off the UI thread.
Future<void> _writePngBytes(Map<String, dynamic> args) async {
  final Uint8List pngBytes = args['pngBytes'] as Uint8List;
  final String path = args['path'] as String;

  // Write to disk immediately so Native RAM doesn't balloon over 50MB
  File(path).writeAsBytesSync(pngBytes);
}

class LaminarMp4Exporter {
  Directory? _framesDir;
  Directory? _tempDir;
  int _fps = 30;
  String _qualityName = 'HD';
  int _frameCount = 0;

  Future<void> initialize({
    required int fps,
    required int width,
    required int height,
    required String qualityName,
  }) async {
    _fps = fps;
    _qualityName = qualityName;
    _frameCount = 0;

    _tempDir = await getTemporaryDirectory();
    _framesDir = Directory('${_tempDir!.path}/laminar_frames');
    if (await _framesDir!.exists()) {
      await _framesDir!.delete(recursive: true);
    }
    await _framesDir!.create();
  }

  Future<void> addFrame(Uint8List pngBytes) async {
    final path = '${_framesDir!.path}/frame_${_frameCount.toString().padLeft(4, '0')}.png';
    // Run PNG disk write completely off the main thread
    await compute(_writePngBytes, {'pngBytes': pngBytes, 'path': path});
    _frameCount++;
  }

  Future<String> export(void Function(double) onProgress) async {
    if (_framesDir == null || _tempDir == null) throw Exception('Exporter not initialized');

    onProgress(0.5);

    final outputPath = '${_tempDir!.path}/laminar_export_${_qualityName}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final outFile = File(outputPath);
    if (await outFile.exists()) {
      await outFile.delete();
    }

    final command =
        '-framerate $_fps -i ${_framesDir!.path}/frame_%04d.png -vf scale=trunc(iw/2)*2:trunc(ih/2)*2 -c:v libx264 -preset slow -profile:v high -level:v 5.1 -crf 18 -color_primaries bt709 -color_trc bt709 -colorspace bt709 -pix_fmt yuv420p $outputPath';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      onProgress(1.0);
      return outputPath;
    } else {
      final logs = await session.getLogs();
      final logStrings = logs.map((l) => l.getMessage()).join('\n');
      throw Exception('FFmpeg process failed with code: $returnCode\nLogs: $logStrings');
    }
  }

  Future<void> dispose() async {
    if (_framesDir != null && await _framesDir!.exists()) {
      try {
        await _framesDir!.delete(recursive: true);
      } catch (_) {}
    }
  }
}
