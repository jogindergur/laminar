import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/laminar.dart';

void main() {
  // ── VideoConfig ────────────────────────────────────────────────────────────
  group('VideoConfig', () {
    test('creates with required fields', () {
      const config = VideoConfig(id: 'test', width: 1920, height: 1080, fps: 30, durationInFrames: 300);
      expect(config.id, 'test');
      expect(config.width, 1920);
      expect(config.height, 1080);
      expect(config.fps, 30);
      expect(config.durationInFrames, 300);
    });

    test('computes durationInSeconds correctly', () {
      const config = VideoConfig(id: 'test', width: 1920, height: 1080, fps: 30, durationInFrames: 300);
      expect(config.durationInSeconds, closeTo(10.0, 0.001));
    });

    test('computes aspectRatio correctly', () {
      const config = VideoConfig(id: 'test', width: 1920, height: 1080, fps: 30, durationInFrames: 300);
      expect(config.aspectRatio, closeTo(16 / 9, 0.001));
    });

    test('copyWith overrides fields', () {
      const base = VideoConfig(id: 'base', width: 1280, height: 720, fps: 24, durationInFrames: 120);
      final copy = base.copyWith(id: 'copy', fps: 60);
      expect(copy.id, 'copy');
      expect(copy.fps, 60);
      expect(copy.width, 1280); // unchanged
    });

    test('round-trips through JSON', () {
      const config = VideoConfig(
        id: 'json-test',
        width: 1920,
        height: 1080,
        fps: 30,
        durationInFrames: 90,
        defaultCodec: Codec.h264,
      );
      final json = config.toJson();
      final restored = VideoConfig.fromJson(json);
      expect(restored, config);
    });
  });

  // ── FrameRange ─────────────────────────────────────────────────────────────
  group('FrameRange', () {
    test('length is inclusive', () {
      const r = FrameRange(start: 0, end: 9);
      expect(r.length, 10);
    });

    test('single frame range has length 1', () {
      const r = FrameRange.single(5);
      expect(r.length, 1);
      expect(r.frames.toList(), [5]);
    });

    test('frames returns correct sequence', () {
      const r = FrameRange(start: 2, end: 5);
      expect(r.frames.toList(), [2, 3, 4, 5]);
    });
  });

  // ── Codec ──────────────────────────────────────────────────────────────────
  group('Codec', () {
    test('h264 extension is mp4', () {
      expect(Codec.h264.extension, 'mp4');
    });

    test('gif extension is gif', () {
      expect(Codec.gif.extension, 'gif');
    });

    test('mp3 is not a video codec', () {
      expect(Codec.mp3.isVideoCodec, false);
    });

    test('h265 is a video codec', () {
      expect(Codec.h265.isVideoCodec, true);
    });
  });

  // ── interpolate ────────────────────────────────────────────────────────────
  group('interpolate()', () {
    test('linear mapping within range', () {
      expect(interpolate(15, [0, 30], [0.0, 1.0]), closeTo(0.5, 0.001));
    });

    test('clamp extrapolation on right', () {
      final result = interpolate(60, [0, 30], [0.0, 1.0], extrapolateRight: Extrapolate.clamp);
      expect(result, closeTo(1.0, 0.001));
    });

    test('clamp extrapolation on left', () {
      final result = interpolate(-10, [0, 30], [0.0, 1.0], extrapolateLeft: Extrapolate.clamp);
      expect(result, closeTo(0.0, 0.001));
    });

    test('extend (default) extrapolates beyond right boundary', () {
      final result = interpolate(60, [0, 30], [0.0, 1.0]);
      expect(result, closeTo(2.0, 0.001));
    });

    test('multi-segment input range', () {
      // 0→0 at frame 0, 0→1 in frames 0-30, 1→0 in frames 30-60
      final result = interpolate(45, [0, 30, 60], [0.0, 1.0, 0.0]);
      expect(result, closeTo(0.5, 0.001));
    });
  });

  // ── Easing ────────────────────────────────────────────────────────────────
  group('Easing', () {
    test('linear returns t', () {
      expect(LaminarEasing.linear(0.5), closeTo(0.5, 0.001));
    });

    test('easeIn is convex', () {
      // f(0.5) < 0.5 for ease-in
      expect(LaminarEasing.easeIn(0.5), lessThan(0.5));
    });

    test('easeOut is concave', () {
      // f(0.5) > 0.5 for ease-out
      expect(LaminarEasing.easeOut(0.5), greaterThan(0.5));
    });

    test('easeInOut is symmetric', () {
      final a = LaminarEasing.easeInOut(0.25);
      final b = 1 - LaminarEasing.easeInOut(0.75);
      expect(a, closeTo(b, 0.001));
    });

    test('boundary conditions: f(0)==0, f(1)==1', () {
      for (final fn in [
        LaminarEasing.linear,
        LaminarEasing.easeIn,
        LaminarEasing.easeOut,
        LaminarEasing.easeInOut,
        LaminarEasing.easeInSine,
        LaminarEasing.easeOutSine,
        LaminarEasing.easeInCubic,
        LaminarEasing.easeOutCubic,
      ]) {
        expect(fn(0.0), closeTo(0.0, 0.001), reason: 'f(0) must equal 0');
        expect(fn(1.0), closeTo(1.0, 0.001), reason: 'f(1) must equal 1');
      }
    });
  });

  // ── RenderMediaOptions ────────────────────────────────────────────────────
  group('RenderMediaOptions', () {
    const baseConfig = VideoConfig(id: 'opts-test', width: 1280, height: 720, fps: 30, durationInFrames: 60);

    test('effectiveFrameRange covers full composition by default', () {
      const opts = RenderMediaOptions(composition: baseConfig);
      expect(opts.effectiveFrameRange.start, 0);
      expect(opts.effectiveFrameRange.end, 59);
      expect(opts.effectiveFrameRange.length, 60);
    });

    test('effectiveFrameRange respects explicit frameRange', () {
      const opts = RenderMediaOptions(composition: baseConfig, frameRange: FrameRange(start: 10, end: 29));
      expect(opts.effectiveFrameRange.length, 20);
    });

    test('default codec is h264', () {
      const opts = RenderMediaOptions(composition: baseConfig);
      expect(opts.codec, Codec.h264);
    });
  });

  // ── LaminarController ─────────────────────────────────────────────────────
  group('LaminarController', () {
    test('initial state is idle at frame 0', () {
      final ctrl = LaminarController()..attach(durationInFrames: 60);
      expect(ctrl.frame, 0);
      expect(ctrl.status, PlaybackStatus.idle);
      expect(ctrl.isPlaying, false);
      ctrl.dispose();
    });

    test('play() sets status to playing', () {
      final ctrl = LaminarController()..attach(durationInFrames: 60);
      ctrl.play();
      expect(ctrl.isPlaying, true);
      expect(ctrl.status, PlaybackStatus.playing);
      ctrl.dispose();
    });

    test('pause() sets status to paused', () {
      final ctrl = LaminarController()
        ..attach(durationInFrames: 60)
        ..play();
      ctrl.pause();
      expect(ctrl.isPaused, true);
      expect(ctrl.status, PlaybackStatus.paused);
      ctrl.dispose();
    });

    test('toggle() switches between playing and paused', () {
      final ctrl = LaminarController()..attach(durationInFrames: 60);
      ctrl.toggle(); // idle → playing
      expect(ctrl.isPlaying, true);
      ctrl.toggle(); // playing → paused
      expect(ctrl.isPaused, true);
      ctrl.dispose();
    });

    test('stop() resets to frame 0 and idle', () {
      final ctrl = LaminarController()
        ..attach(durationInFrames: 60)
        ..play();
      ctrl.seekTo(30);
      ctrl.stop();
      expect(ctrl.frame, 0);
      expect(ctrl.status, PlaybackStatus.idle);
      ctrl.dispose();
    });

    test('seekTo clamps to valid range', () {
      final ctrl = LaminarController()..attach(durationInFrames: 60);
      ctrl.seekTo(200);
      expect(ctrl.frame, 59);
      ctrl.seekTo(-10);
      expect(ctrl.frame, 0);
      ctrl.dispose();
    });

    test('stepForward increments frame', () {
      final ctrl = LaminarController()..attach(durationInFrames: 60);
      ctrl.stepForward();
      expect(ctrl.frame, 1);
      ctrl.dispose();
    });

    test('stepBack decrements frame (clamped at 0)', () {
      final ctrl = LaminarController()..attach(durationInFrames: 60);
      ctrl.stepBack(); // already at 0 — clamps
      expect(ctrl.frame, 0);
      ctrl.seekTo(10);
      ctrl.stepBack();
      expect(ctrl.frame, 9);
      ctrl.dispose();
    });

    test('advance() increments frame while playing', () {
      final ctrl = LaminarController()
        ..attach(durationInFrames: 60)
        ..play();
      expect(ctrl.advance(loop: false), true);
      expect(ctrl.frame, 1);
      ctrl.dispose();
    });

    test('advance() at last frame sets status to finished (no loop)', () {
      final ctrl = LaminarController()
        ..attach(durationInFrames: 3)
        ..play();
      ctrl.advance(loop: false); // → frame 1
      ctrl.advance(loop: false); // → frame 2
      ctrl.advance(loop: false); // → finished (last frame = 2)
      expect(ctrl.status, PlaybackStatus.finished);
      expect(ctrl.isFinished, true);
      ctrl.dispose();
    });

    test('advance() loops when loop=true', () {
      final ctrl = LaminarController()
        ..attach(durationInFrames: 3)
        ..play();
      ctrl.advance(loop: true); // 1
      ctrl.advance(loop: true); // 2
      ctrl.advance(loop: true); // → wraps to 0
      expect(ctrl.frame, 0);
      expect(ctrl.isPlaying, true);
      ctrl.dispose();
    });

    test('progress is 0.0 at frame 0 and 1.0 at last frame', () {
      final ctrl = LaminarController()..attach(durationInFrames: 10);
      expect(ctrl.progress, closeTo(0.0, 0.001));
      ctrl.seekTo(9);
      expect(ctrl.progress, closeTo(1.0, 0.001));
      ctrl.dispose();
    });

    test('notifies listeners on state changes', () {
      final ctrl = LaminarController()..attach(durationInFrames: 60);
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.play();
      ctrl.seekTo(10);
      ctrl.pause();
      ctrl.stop();
      expect(notifyCount, 4);
      ctrl.dispose();
    });

    test('play() is no-op when already playing', () {
      final ctrl = LaminarController()
        ..attach(durationInFrames: 60)
        ..play();
      int count = 0;
      ctrl.addListener(() => count++);
      ctrl.play(); // should not notify
      expect(count, 0);
      ctrl.dispose();
    });
  });
}
