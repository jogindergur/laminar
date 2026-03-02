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
///     _ctrl = LaminarController()
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
  LaminarController({int initialFrame = 0}) : assert(initialFrame >= 0) {
    _frame = initialFrame;
  }
  int _durationInFrames = 0;
  int _frame = 0;
  PlaybackStatus _status = PlaybackStatus.idle;

  /// Called by `Composition` when this controller is attached.
  /// This provides the controller with the necessary bounds for playback.
  void attach({required int durationInFrames}) {
    assert(durationInFrames > 0);
    _durationInFrames = durationInFrames;
    _frame = _frame.clamp(0, durationInFrames > 0 ? durationInFrames - 1 : 0);
  }

  /// Total number of frames in the active composition.
  /// Will return 0 if the controller has not yet been attached to a Composition.
  int get durationInFrames => _durationInFrames;

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

  /// Playback progress in [0.0, 1.0]. Returns 0.0 if not attached.
  double get progress => _durationInFrames > 1
      ? _frame / (_durationInFrames - 1)
      : (_durationInFrames == 1 ? 1.0 : 0.0);

  // ── Commands ─────────────────────────────────────────────────────────────

  /// Starts playback from the current frame. No-op if already playing.
  ///
  /// If the composition has [finished], playback restarts from frame 0.
  void play() {
    if (_status == PlaybackStatus.playing) return;
    // If we finished, rewind so the very first advance() tick isn't a no-op.
    if (_status == PlaybackStatus.finished) {
      _frame = 0;
    }
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
    if (_durationInFrames == 0) {
      _frame = frame; // Allow pre-seeking if not attached yet
    } else {
      _frame = frame.clamp(0, _durationInFrames - 1);
    }
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
  bool advance({required bool loop}) {
    if (_status != PlaybackStatus.playing || _durationInFrames == 0) {
      return false;
    }
    if (_frame >= _durationInFrames - 1) {
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
  String toString() =>
      'LaminarController(frame: $_frame/$_durationInFrames, status: $_status)';
}

/// Playback status of a [LaminarController].
enum PlaybackStatus {
  /// Not yet started or stopped (frame is at 0).
  idle,

  /// Actively playing.
  playing,

  /// Paused at some frame, ready to resume.
  paused,

  /// Reached the last frame and [Composition.loop] is false.
  finished,
}
