import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/src/models/render_media_progress.dart';
import 'package:laminar/src/models/render_media_result.dart';
import 'package:laminar/src/models/slow_frame.dart';

void main() {
  group('Models', () {
    test('SlowFrame initializes and stringifies correctly', () {
      const slowFrame = SlowFrame(frame: 15, timeMs: 400);
      expect(slowFrame.frame, 15);
      expect(slowFrame.timeMs, 400);
      expect(slowFrame.toString(), 'SlowFrame(frame: 15, timeMs: 400)');
    });

    test('RenderMediaProgress initializes and stringifies correctly', () {
      const progress = RenderMediaProgress(
        renderedFrames: 30,
        totalFrames: 60,
        progress: 0.5,
        slowFrames: [SlowFrame(frame: 10, timeMs: 500)],
        estimatedRemainingMs: 3000,
      );

      expect(progress.renderedFrames, 30);
      expect(progress.totalFrames, 60);
      expect(progress.progress, 0.5);
      expect(progress.slowFrames.length, 1);
      expect(progress.estimatedRemainingMs, 3000);
      expect(progress.isComplete, false);
      expect(progress.toString(), 'RenderMediaProgress(50.0% – 30/60 frames)');
    });

    test('RenderMediaProgress.initial creates correct initial state', () {
      final initial = RenderMediaProgress.initial(100);
      expect(initial.renderedFrames, 0);
      expect(initial.totalFrames, 100);
      expect(initial.progress, 0.0);
      expect(initial.isComplete, false);
    });

    test('RenderMediaProgress isComplete returns true when done', () {
      const complete = RenderMediaProgress(
        renderedFrames: 100,
        totalFrames: 100,
        progress: 1.0,
      );
      expect(complete.isComplete, true);
    });

    test('RenderMediaResult initializes and stringifies correctly', () {
      const result = RenderMediaResult(
        outputPath: '/path/to/output.mp4',
        durationMs: 5000,
        totalFrames: 120,
        slowFrames: [SlowFrame(frame: 5, timeMs: 300)],
      );

      expect(result.outputPath, '/path/to/output.mp4');
      expect(result.durationMs, 5000);
      expect(result.totalFrames, 120);
      expect(result.slowFrames.length, 1);
      expect(
        result.toString(),
        'RenderMediaResult(output: /path/to/output.mp4, 120f in 5000ms)',
      );
    });
  });
}
