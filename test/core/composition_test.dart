import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/src/core/composition.dart';
import 'package:laminar/src/core/composition_provider.dart';
import 'package:laminar/src/core/laminar_controller.dart';
import 'package:laminar/src/models/video_config.dart';

void main() {
  group('Composition Widget', () {
    testWidgets('initializes internal controller and provides context', (tester) async {
      int? builtFrame;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Composition<void>(
            config: const VideoConfig(id: 'test_comp', width: 1920, height: 1080, fps: 30, durationInFrames: 60),
            defaultProps: null,
            serialize: (_) => {},
            component: (context, props) {
              builtFrame = CompositionProvider.frameOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(builtFrame, 0);
    });

    testWidgets('uses external controller if provided', (tester) async {
      final ctrl = LaminarController();
      ctrl.attach(durationInFrames: 60);
      ctrl.seekTo(15);

      int? builtFrame;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Composition<void>(
            config: const VideoConfig(id: 'test_comp', width: 1920, height: 1080, fps: 30, durationInFrames: 60),
            defaultProps: null,
            serialize: (_) => {},
            controller: ctrl,
            component: (context, props) {
              builtFrame = CompositionProvider.frameOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(builtFrame, 15);

      // Update external controller.
      ctrl.seekTo(20);
      await tester.pumpAndSettle();
      expect(builtFrame, 20);

      ctrl.dispose();
    });

    testWidgets('autoPlay starts internal ticker automatically', (tester) async {
      int builtFrame = -1;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Composition<void>(
            config: const VideoConfig(id: 'test_comp', width: 1920, height: 1080, fps: 30, durationInFrames: 60),
            defaultProps: null,
            serialize: (_) => {},
            autoPlay: true,
            component: (context, props) {
              builtFrame = CompositionProvider.frameOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(builtFrame, 0);

      // Advance time to let the timer tick. At 30fps, 33ms is ~1 frame.
      await tester.pump(const Duration(milliseconds: 35));
      expect(builtFrame, 1);
    });
  });
}
