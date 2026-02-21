import 'package:flutter/foundation.dart';

/// Controls the playback state of a [Composition] widget.
///
/// [LaminarController] is the Laminar equivalent of Flutter's
/// [AnimationController] — it owns the frame cursor and lets you drive a
/// composition programmatically from anywhere in the widget tree.
///
/// ### Typical usage
/// ```dart
/// class _MyState extends State<MyPage> {
///   late final LaminarController _ctrl;
///
///   @override
///   void initState() {
///     super.initState();
///     _ctrl = LaminarController(durationInFrames: 90, fps: 30)
///       ..play(); // auto-start
///   }
///
///   @override
///   void dispose() {
///     _ctrl.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Composition<MyProps>(
///       controller: _ctrl,
///       // …other params…
///     );
///   }
/// }
/// ```
///
/// When no controller is passed to [Composition], a default one is created
/// and owned internally — the composition simply auto-plays on build.
class LaminarController extends ChangeNotifier {
  /// Total number of frames in the composition this controller drives.
  final int durationInFrames;

  /// Frames per second.
  final int fps;

  /// Whether playback restarts from frame 0 after the last frame.
  bool loop;

  int _frame = 0;
  PlaybackStatus _status = PlaybackStatus.idle;

  LaminarController({required this.durationInFrames, required this.fps, this.loop = false, int initialFrame = 0})
    : assert(durationInFrames > 0),
      assert(fps > 0),
      assert(initialFrame >= 0 && initialFrame < durationInFrames) {
    _frame = initialFrame;
  }

  // ── State ─────────────────────────────────────────────────────────────────

  /// The current zero-based frame index.
  int get frame => _frame;

  /// Current playback status.
  PlaybackStatus get status => _status;

  /// `true` while the composition is playing.
  bool get isPlaying => _status == PlaybackStatus.playing;

  /// `true` if playback has been explicitly paused.
  bool get isPaused => _status == PlaybackStatus.paused;

  /// `true` if the composition is at its last frame and not playing.
  bool get isFinished => _status == PlaybackStatus.finished;

  /// Playback progress in [0.0, 1.0].
  double get progress => durationInFrames > 1 ? _frame / (durationInFrames - 1) : 1.0;

  // ── Commands ─────────────────────────────────────────────────────────────

  /// Starts playback from the current frame. No-op if already playing.
  void play() {
    if (_status == PlaybackStatus.playing) return;
    _status = PlaybackStatus.playing;
    notifyListeners();
  }

  /// Pauses playback at the current frame.
  void pause() {
    if (_status != PlaybackStatus.playing) return;
    _status = PlaybackStatus.paused;
    notifyListeners();
  }

  /// Toggles between playing and paused.
  void toggle() => isPlaying ? pause() : play();

  /// Stops playback and resets to frame 0.
  void stop() {
    _status = PlaybackStatus.idle;
    _frame = 0;
    notifyListeners();
  }

  /// Seeks to a specific [frame] index. Clamps to valid range.
  void seekTo(int frame) {
    _frame = frame.clamp(0, durationInFrames - 1);
    notifyListeners();
  }

  /// Advances one frame forward. Useful for step-through.
  void stepForward() => seekTo(_frame + 1);

  /// Steps one frame back.
  void stepBack() => seekTo(_frame - 1);

  // ── Internal: called by [Composition] on each ticker tick ─────────────────

  /// Advances the frame by one tick. Called by the [Composition] widget's
  /// internal [Ticker]. Returns `true` if the frame was advanced, `false` if
  /// the animation reached its end.
  bool advance() {
    if (_status != PlaybackStatus.playing) return false;
    if (_frame >= durationInFrames - 1) {
      if (loop) {
        _frame = 0;
      } else {
        _status = PlaybackStatus.finished;
      }
      notifyListeners();
      return false;
    }
    _frame++;
    notifyListeners();
    return true;
  }

  @override
  String toString() => 'LaminarController(frame: $_frame/$durationInFrames, status: $_status)';
}

/// Playback status of a [LaminarController].
enum PlaybackStatus {
  /// Not yet started or stopped (frame is at 0).
  idle,

  /// Actively playing.
  playing,

  /// Paused at some frame, ready to resume.
  paused,

  /// Reached the last frame and [LaminarController.loop] is false.
  finished,
}
