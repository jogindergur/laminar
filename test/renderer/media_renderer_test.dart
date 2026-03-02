import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/src/models/render_media_options.dart';
import 'package:laminar/src/models/render_media_progress.dart';
import 'package:laminar/src/models/video_config.dart';
import 'package:laminar/src/renderer/media_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaRenderer', () {
    const config = VideoConfig(
      id: 'media_test',
      width: 50,
      height: 50,
      fps: 30,
      durationInFrames: 5, // Keep test short
    );

    test('renders multiple frames and emits progress', () async {
      const options = RenderMediaOptions(
        composition: config,
        outputLocation: '/tmp/output.mp4',
        concurrency: 2,
      );

      final renderer = MediaRenderer(options: options);

      final progressEvents = <RenderMediaProgress>[];
      renderer.onProgress.listen(progressEvents.add);

      final result = await renderer.render(
        widgetFactory: (frame) =>
            const SizedBox.expand(child: ColoredBox(color: Color(0xFF00FF00))),
      );

      expect(result.totalFrames, 5);
      expect(result.outputPath, '/tmp/output.mp4');

      // The events should be emitted in chunks based on concurrency.
      // initial (0), after batch 1 (2 frames), after batch 2 (4 frames), after batch 3 (5 frames)
      expect(progressEvents, isNotEmpty);
      expect(progressEvents.first.renderedFrames, 0);
      expect(progressEvents.first.progress, 0.0);

      expect(progressEvents.last.renderedFrames, 5);
      expect(progressEvents.last.progress, 1.0);
      expect(progressEvents.last.isComplete, true);
    });

    test('slow frame threshold is respected', () async {
      final options = RenderMediaOptions(
        composition: config.copyWith(durationInFrames: 1),
        slowFrameThresholdMs: -1, // Force every frame to be "slow"
      );

      final renderer = MediaRenderer(options: options);
      final result = await renderer.render(
        widgetFactory: (frame) =>
            const SizedBox.expand(child: ColoredBox(color: Color(0xFF00FF00))),
      );

      expect(result.slowFrames.length, 1);
      expect(result.slowFrames.first.frame, 0);
    });
  });
}
