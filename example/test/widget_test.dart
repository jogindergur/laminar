import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/laminar.dart';

import 'package:laminar_example/compositions/fade_title_composition.dart';
import 'package:laminar_example/compositions/counter_composition.dart';
import 'package:laminar_example/compositions/wave_composition.dart';
import 'package:laminar_example/compositions/series_demo_composition.dart';
import 'package:laminar_example/app.dart';

// Helper: wraps a widget in CompositionProvider for testing.
Widget _withComposition({
  required Widget child,
  int frame = 0,
  String id = 'test',
  int durationInFrames = 90,
  int fps = 30,
}) {
  return MaterialApp(
    home: Scaffold(
      body: CompositionProvider(
        config: VideoConfig(
          id: id,
          width: 1920,
          height: 1080,
          fps: fps,
          durationInFrames: durationInFrames,
        ),
        frame: frame,
        child: child,
      ),
    ),
  );
}

void main() {
  // ── App smoke test ─────────────────────────────────────────────────────────
  group('LaminarExampleApp', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(const LaminarExampleApp());
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('shows gallery screen with all 4 composition cards',
        (tester) async {
      await tester.pumpWidget(const LaminarExampleApp());
      await tester.pump();
      expect(find.text('Laminar Demo Gallery'), findsOneWidget);
      expect(find.text('Fade Title'), findsOneWidget);
      expect(find.text('Animated Counter'), findsOneWidget);
      expect(find.text('Audio Wave'), findsOneWidget);
      expect(find.text('Series Scenes'), findsOneWidget);
    });
  });

  // ── FadeTitleComposition ───────────────────────────────────────────────────
  group('FadeTitleComposition', () {
    testWidgets('renders at frame 0 without error', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const FadeTitleComposition(),
        frame: 0,
      ));
      await tester.pump();
      expect(find.byType(FadeTitleComposition), findsOneWidget);
    });

    testWidgets('title text is visible at frame 45', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const FadeTitleComposition(),
        frame: 45,
      ));
      await tester.pump();
      expect(find.text('Hello, Laminar!'), findsOneWidget);
    });

    testWidgets('renders at last frame (89) without error', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const FadeTitleComposition(),
        frame: 89,
      ));
      await tester.pump();
      expect(find.byType(FadeTitleComposition), findsOneWidget);
    });
  });

  // ── CounterComposition ────────────────────────────────────────────────────
  group('CounterComposition', () {
    testWidgets('renders at frame 0 showing "0"', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const CounterComposition(),
        frame: 0,
        durationInFrames: 120,
      ));
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders at frame 100 showing "100"', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const CounterComposition(),
        frame: 100,
        durationInFrames: 120,
      ));
      await tester.pump();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('mid-frame (50) renders without error', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const CounterComposition(),
        frame: 50,
        durationInFrames: 120,
      ));
      await tester.pump();
      expect(find.byType(CounterComposition), findsOneWidget);
    });
  });

  // ── WaveComposition ───────────────────────────────────────────────────────
  group('WaveComposition', () {
    testWidgets('renders at frame 0 without error', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const WaveComposition(),
        frame: 0,
      ));
      await tester.pump();
      expect(find.byType(WaveComposition), findsOneWidget);
    });

    testWidgets('LAMINAR WAVE label visible at frame 45', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const WaveComposition(),
        frame: 45,
      ));
      await tester.pump();
      expect(find.text('LAMINAR WAVE'), findsOneWidget);
    });
  });

  // ── SeriesDemoComposition ─────────────────────────────────────────────────
  group('SeriesDemoComposition — Series/Sequence routing', () {
    testWidgets('scene 1 (Introduction) visible at frame 10', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const SeriesDemoComposition(),
        frame: 10,
        durationInFrames: 150,
      ));
      await tester.pump();
      expect(find.text('Introduction'), findsOneWidget);
    });

    testWidgets('scene 2 (Core Primitives) visible at frame 70', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const SeriesDemoComposition(),
        frame: 70,
        durationInFrames: 150,
      ));
      await tester.pump();
      expect(find.text('Core Primitives'), findsOneWidget);
    });

    testWidgets('scene 3 (Outro) visible at frame 120', (tester) async {
      await tester.pumpWidget(_withComposition(
        child: const SeriesDemoComposition(),
        frame: 120,
        durationInFrames: 150,
      ));
      await tester.pump();
      expect(find.text('laminar'), findsOneWidget);
    });
  });

  // ── CompositionProvider integration ───────────────────────────────────────
  group('CompositionProvider integration', () {
    testWidgets('useCurrentFrame returns injected frame value', (tester) async {
      int? capturedFrame;
      await tester.pumpWidget(
        _withComposition(
          frame: 42,
          child: Builder(builder: (ctx) {
            capturedFrame = useCurrentFrame(ctx);
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pump();
      expect(capturedFrame, 42);
    });

    testWidgets('useVideoConfig returns injected config', (tester) async {
      VideoConfig? capturedConfig;
      await tester.pumpWidget(
        _withComposition(
          id: 'cfg-test',
          fps: 60,
          durationInFrames: 200,
          child: Builder(builder: (ctx) {
            capturedConfig = useVideoConfig(ctx);
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pump();
      expect(capturedConfig?.id, 'cfg-test');
      expect(capturedConfig?.fps, 60);
      expect(capturedConfig?.durationInFrames, 200);
    });

    testWidgets(
        'throws FlutterError when useVideoConfig called outside CompositionProvider',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (ctx) {
            expect(
              () => useVideoConfig(ctx),
              throwsA(isA<FlutterError>()),
            );
            return const SizedBox.shrink();
          }),
        ),
      );
    });
  });
}
