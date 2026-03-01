import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/video_config.dart';
import 'composition_provider.dart';
import 'laminar_controller.dart';

/// A self-animating Flutter widget that represents a named video composition.
///
/// **Laminar compositions are regular Flutter widgets.** You can embed them
/// directly inside any layout — [Column], [Stack], [Card], [SizedBox], etc. —
/// without any player scaffolding.
///
/// ```dart
/// // Drop-in anywhere:
/// SizedBox(
///   width: 400,
///   height: 225,
///   child: Composition<void>(
///     id: 'hero',
///     width: 1920, height: 1080, fps: 30,
///     durationInFrames: 90,
///     defaultProps: null,
///     serialize: (_) => {},
///     component: (ctx, _) => const MyHeroScene(),
///     autoPlay: true,
///   ),
/// )
/// ```
///
/// ### Controller
/// Pass a [LaminarController] to control playback externally (play, pause,
/// seek, loop). When no controller is passed, Laminar creates and owns one
/// internally; set [autoPlay] to `true` to start it automatically.
///
/// ```dart
/// // Controlled externally:
/// final ctrl = LaminarController(durationInFrames: 90, fps: 30);
/// // … in build:
/// Composition<MyProps>(controller: ctrl, …)
/// ```
///
/// ### Sizing
/// [Composition] fills its parent by default. Wrap it in a [SizedBox] or
/// [AspectRatio] to constrain it — just like any other widget.
class Composition<T> extends StatefulWidget {

  const Composition({
    super.key,
    required this.config,
    required this.defaultProps,
    required this.serialize,
    required this.component,
    this.controller,
    this.autoPlay = false,
    this.loop = false,
  });
  // ── Identity ──────────────────────────────────────────────────────────────

  /// The master metadata entity describing this composition's render context.
  final VideoConfig config;

  // ── Props ─────────────────────────────────────────────────────────────────

  /// Default props passed to [component].
  final T defaultProps;

  /// Converts [defaultProps] to a JSON-compatible map (required because Dart
  /// lacks Zod-style runtime schemas).
  final Map<String, dynamic> Function(T props) serialize;

  // ── Widget factory ────────────────────────────────────────────────────────

  /// The root widget of this composition. Receives [BuildContext] and the
  /// resolved [T] props. Sub-widgets access the current frame via
  /// [useCurrentFrame(context)] and metadata via [useVideoConfig(context)].
  final Widget Function(BuildContext context, T props) component;

  // ── Playback ──────────────────────────────────────────────────────────────

  /// Optional external controller. When `null`, an internal controller is
  /// created and owned by this widget.
  final LaminarController? controller;

  /// Whether to start playback immediately on first build.
  ///
  /// Only applies to the *internal* controller (ignored when [controller] is
  /// supplied — the external controller manages its own state).
  final bool autoPlay;

  /// Whether to loop playback when the last frame is reached.
  ///
  /// Only applies to the *internal* controller.
  final bool loop;

  @override
  State<Composition<T>> createState() => _CompositionState<T>();
}

class _CompositionState<T> extends State<Composition<T>> {
  late LaminarController _ctrl;
  bool _ownsController = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(Composition<T> old) {
    super.didUpdateWidget(old);
    // If the external controller reference changed, re-attach.
    if (old.controller != widget.controller) {
      _detachController();
      _attachController();
    }
  }

  // ── Controller lifecycle ──────────────────────────────────────────────────

  void _attachController() {
    if (widget.controller != null) {
      _ctrl = widget.controller!;
      _ownsController = false;
    } else {
      _ctrl = LaminarController();
      _ownsController = true;
    }

    // Always attach the controller to the current configuration bounds
    _ctrl.attach(durationInFrames: widget.config.durationInFrames);

    if (_ownsController && widget.autoPlay) {
      _ctrl.play();
    }

    _ctrl.addListener(_onControllerChanged);
    _startTicker();
  }

  void _detachController() {
    _stopTicker();
    _ctrl.removeListener(_onControllerChanged);
    if (_ownsController) _ctrl.dispose();
  }

  void _onControllerChanged() {
    // Mirror controller state to ticker.
    if (_ctrl.isPlaying) {
      _startTicker();
    } else {
      _stopTicker();
    }
    if (mounted) setState(() {});
  }

  // ── Frame ticker ─────────────────────────────────────────────────────────

  void _startTicker() {
    if (_ticker != null) return; // already running
    final interval = Duration(microseconds: (1000000 / widget.config.fps).round());
    _ticker = Timer.periodic(interval, (_) {
      if (!_ctrl.isPlaying) {
        _stopTicker();
        return;
      }
      _ctrl.advance(loop: widget.loop);
      if (mounted) setState(() {});
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // We now just use the widget.config injected into the Composition.
    // However, if the config didn't have defaultProps serialized, we serialize them here.
    // In many cases, we might want to just pass an already serialized props map, but
    // to keep the API similar, we can create a modified config.
    final renderConfig = widget.config.copyWith(defaultProps: widget.serialize(widget.defaultProps));

    return CompositionProvider(
      config: renderConfig,
      frame: _ctrl.frame,
      child: Builder(builder: (ctx) => widget.component(ctx, widget.defaultProps)),
    );
  }
}
