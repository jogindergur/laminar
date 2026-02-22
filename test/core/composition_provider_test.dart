import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/laminar.dart';

void main() {
  group('CompositionProvider', () {
    const config = VideoConfig(id: 'test_config', width: 1920, height: 1080, fps: 30, durationInFrames: 60);

    testWidgets('provides config and frame to descendants', (tester) async {
      int? retrievedFrame;
      VideoConfig? retrievedConfig;

      await tester.pumpWidget(
        CompositionProvider(
          config: config,
          frame: 42,
          child: Builder(
            builder: (context) {
              retrievedFrame = CompositionProvider.frameOf(context);
              retrievedConfig = CompositionProvider.configOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedFrame, 42);
      expect(retrievedConfig?.id, 'test_config');
    });

    testWidgets('throws meaningful error if provider is missing', (tester) async {
      FlutterErrorDetails? errorDetails;
      FlutterError.onError = (details) {
        errorDetails = details;
      };

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            CompositionProvider.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(errorDetails, isNotNull);
      expect(errorDetails!.exception.toString(), contains('No CompositionProvider found'));
    });

    test('withFrame creates a copy with updated frame', () {
      final provider = CompositionProvider(config: config, frame: 10, child: const SizedBox());

      final updated = provider.withFrame(20);
      expect(updated.frame, 20);
      expect(updated.config, config);
      expect(updated.child, provider.child);
    });
  });
}
