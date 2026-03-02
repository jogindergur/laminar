import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/src/models/video_config.dart';
import 'package:laminar/src/renderer/frame_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FrameRenderer', () {
    const config = VideoConfig(
      id: 'frame_test',
      width: 100,
      height: 100,
      fps: 30,
      durationInFrames: 60,
    );

    test('renders a simple widget into an image', () async {
      final image = await FrameRenderer.renderFrame(
        frame: 0,
        widget: const SizedBox.expand(
          child: ColoredBox(color: Color(0xFFFF0000)),
        ), // Sized Red box
        config: config,
      );

      expect(image.width, 100);
      expect(image.height, 100);

      // Verify pixel color
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      expect(byteData, isNotNull);

      // Center pixel should be red (RGBA: 255, 0, 0, 255)
      const offset = (50 * 100 + 50) * 4;
      expect(byteData!.getUint8(offset), 255); // R
      expect(byteData.getUint8(offset + 1), 0); // G
      expect(byteData.getUint8(offset + 2), 0); // B
      expect(byteData.getUint8(offset + 3), 255); // A

      image.dispose();
    });
  });
}
