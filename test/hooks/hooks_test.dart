import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/src/core/composition_provider.dart';
import 'package:laminar/src/hooks/use_current_frame.dart';
import 'package:laminar/src/hooks/use_video_config.dart';
import 'package:laminar/src/models/video_config.dart';

void main() {
  group('Hooks', () {
    const config = VideoConfig(
      id: 'hook_test',
      width: 1920,
      height: 1080,
      fps: 30,
      durationInFrames: 60,
    );

    testWidgets('useCurrentFrame returns the correct frame from context', (
      tester,
    ) async {
      int? retrievedFrame;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CompositionProvider(
            config: config,
            frame: 42,
            child: Builder(
              builder: (context) {
                retrievedFrame = useCurrentFrame(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedFrame, 42);
    });

    testWidgets('useVideoConfig returns the correct config from context', (
      tester,
    ) async {
      VideoConfig? retrievedConfig;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CompositionProvider(
            config: config,
            frame: 42,
            child: Builder(
              builder: (context) {
                retrievedConfig = useVideoConfig(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedConfig, config);
    });

    testWidgets('hooks throw explicit error when outside CompositionProvider', (
      tester,
    ) async {
      FlutterErrorDetails? errorDetailsConfig;
      FlutterErrorDetails? errorDetailsFrame;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            try {
              useVideoConfig(context);
            } catch (e) {
              errorDetailsConfig = FlutterErrorDetails(exception: e);
            }

            try {
              useCurrentFrame(context);
            } catch (e) {
              errorDetailsFrame = FlutterErrorDetails(exception: e);
            }
            return const SizedBox();
          },
        ),
      );

      expect(errorDetailsConfig, isNotNull);
      expect(
        errorDetailsConfig!.exception.toString(),
        contains('No CompositionProvider found'),
      );

      expect(errorDetailsFrame, isNotNull);
      expect(
        errorDetailsFrame!.exception.toString(),
        contains('No CompositionProvider found'),
      );
    });
  });
}
