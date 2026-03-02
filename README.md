# Laminar 🎬

## Take a look at: https://easyhub.tech/laminar/

**A platform-independent Flutter library for programmatic animation composition and rendering. User animation is whole new experience.**

Laminar is inspired by [Remotion].

---

## Features

- **Declarative scene composition**: `Composition<T>` widget
- **Playback control**: `LaminarController`
- **Frame-aware context**: `CompositionProvider` (`InheritedWidget`)
- **Current frame accessor**: `useCurrentFrame(context)`
- **Video metadata accessor**: `useVideoConfig(context)`
- **Time-scoped child rendering**: `Sequence`
- **Sequential scene layout**: `Series` + `SeriesSequence`
- **Animation mapping**: `interpolate()`
- **Easing functions**: `Easing.*`
- **Progress events**: `Stream<RenderMediaProgress>`
- **Renderer**: `MediaRenderer` + `FrameRenderer`

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  laminar:
    path: ../laminar  # or git/pub when published
```

---

## Quick Start

### 1. Define a Composition

```dart
import 'package:laminar/laminar.dart';

class MyProps {
  final String title;
  const MyProps({required this.title});
  Map<String, dynamic> toJson() => {'title': title};
}

class MyScene extends StatelessWidget {
  const MyScene({super.key});

  @override
  Widget build(BuildContext context) {
    final frame  = useCurrentFrame(context);
    final config = useVideoConfig(context);

    // Fade in over first 30 frames
    final opacity = interpolate(
      frame,
      [0, 30],
      [0.0, 1.0],
      easing: Easing.easeOutCubic,
      extrapolateRight: Extrapolate.clamp,
    );

    return ColoredBox(
      color: const Color(0xFF0A0A0A),
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Text(
            '${config.id} — frame $frame',
            style: const TextStyle(color: Colors.white, fontSize: 48),
          ),
        ),
      ),
    );
  }
}
```

### 2. Register the Composition

```dart
Composition<MyProps>(
  config: const VideoConfig(
    id: 'my-video',
    width: 1920,
    height: 1080,
    fps: 30,
    durationInFrames: 300,      // 10 seconds
  ),
  defaultProps: const MyProps(title: 'Hello, Laminar!'),
  serialize: (p) => p.toJson(),
  component: (_, __) => const MyScene(),
);
```

### 3. Use Sequence and Series

```dart
Series(
  sequences: [
    SeriesSequence(durationInFrames: 60,  child: TitleCard()),
    SeriesSequence(durationInFrames: 120, child: MainContent()),
    SeriesSequence(durationInFrames: 60,  child: Outro()),
  ],
)
```

### 4. Render to Video

```dart
final options = RenderMediaOptions(
  composition: myConfig,
  outputLocation: '/tmp/output_directory',
  codec: Codec.h264,
  concurrency: 4,
);

final renderer = MediaRenderer(options: options);
renderer.onProgress.listen((p) {
  print('${(p.progress * 100).toStringAsFixed(1)}% '
        '(${p.renderedFrames}/${p.totalFrames} frames)');
});

final result = await renderer.render(
  widgetFactory: (frame) => const MyScene(),
);

print('Rendered to: ${result.outputPath}');
print('Took: ${result.durationMs}ms');
```

---

## Architecture

```
laminar/
├── lib/
│   ├── laminar.dart                  ← Public API barrel
│   └── src/
│       ├── models/
│       │   ├── video_config.dart     ← Master render metadata
│       │   ├── codec.dart            ← Output format enum
│       │   ├── frame_range.dart      ← [start, end] frame window
│       │   ├── render_media_options.dart
│       │   ├── render_media_progress.dart
│       │   ├── render_media_result.dart
│       │   └── slow_frame.dart       ← Metrics entity
│       ├── core/
│       │   ├── composition.dart      ← <Composition /> equivalent
│       │   ├── composition_provider.dart ← InheritedWidget context
│       │   ├── sequence.dart         ← <Sequence /> equivalent
│       │   └── series.dart           ← <Series /> equivalent
│       ├── hooks/
│       │   ├── use_video_config.dart ← useVideoConfig() equivalent
│       │   └── use_current_frame.dart← useCurrentFrame() equivalent
│       ├── interpolate/
│       │   ├── interpolate.dart      ← interpolate() function
│       │   └── easing.dart           ← Easing curves
│       └── renderer/
│           ├── media_renderer.dart   ← render-media.ts equivalent
│           └── frame_renderer.dart   ← Off-screen Flutter rasteriser
└── test/
    └── laminar_test.dart
```

---

## Running Tests

```bash
flutter test
```

---

## Credits

- [Remotion](https://github.com/remotion-dev/remotion), thanks for the inspiration.

## License

Laminar is released under a MIT license. See LICENSE for details.
