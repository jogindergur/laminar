import 'codec.dart';

/// The master metadata entity describing a [Composition]'s render context.
///
/// This is the Dart equivalent of Remotion's `VideoConfig` TypeScript type.
/// It is propagated down the widget tree via [CompositionProvider] and
/// accessed via [useVideoConfig].
class VideoConfig {
  const VideoConfig({
    required this.id,
    required this.width,
    required this.height,
    required this.fps,
    required this.durationInFrames,
    this.defaultProps = const {},
    this.defaultCodec,
  }) : assert(width > 0, 'width must be positive'),
       assert(height > 0, 'height must be positive'),
       assert(fps > 0, 'fps must be positive'),
       assert(durationInFrames > 0, 'durationInFrames must be positive');

  /// Deserializes a [VideoConfig] from a JSON map.
  factory VideoConfig.fromJson(Map<String, dynamic> json) {
    return VideoConfig(
      id: json['id'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      fps: json['fps'] as int,
      durationInFrames: json['durationInFrames'] as int,
      defaultProps: (json['defaultProps'] as Map<String, dynamic>?) ?? const {},
      defaultCodec: json['defaultCodec'] != null
          ? Codec.values.byName(json['defaultCodec'] as String)
          : null,
    );
  }

  /// Unique identifier for this composition (maps to the Remotion `id` prop).
  final String id;

  /// Output width in pixels.
  final int width;

  /// Output height in pixels.
  final int height;

  /// Frames per second. Typical values: 24, 30, 60.
  final int fps;

  /// Total number of frames in this composition.
  final int durationInFrames;

  /// Default props passed to the root composition widget.
  ///
  /// In TypeScript/Remotion these are typed via a Zod schema. In Dart they
  /// are a plain `Map<String, dynamic>` and must be cast / deserialized by
  /// the consuming widget or a typed wrapper.
  final Map<String, dynamic> defaultProps;

  /// Preferred output codec. May be overridden by [RenderMediaOptions].
  final Codec? defaultCodec;

  /// Total duration of the composition in seconds.
  double get durationInSeconds => durationInFrames / fps;

  /// Aspect ratio (width / height).
  double get aspectRatio => width / height;

  /// Returns a copy of this [VideoConfig] with the given fields overridden.
  VideoConfig copyWith({
    String? id,
    int? width,
    int? height,
    int? fps,
    int? durationInFrames,
    Map<String, dynamic>? defaultProps,
    Codec? defaultCodec,
  }) {
    return VideoConfig(
      id: id ?? this.id,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
      durationInFrames: durationInFrames ?? this.durationInFrames,
      defaultProps: defaultProps ?? this.defaultProps,
      defaultCodec: defaultCodec ?? this.defaultCodec,
    );
  }

  /// Serializes this [VideoConfig] to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'width': width,
    'height': height,
    'fps': fps,
    'durationInFrames': durationInFrames,
    'defaultProps': defaultProps,
    if (defaultCodec != null) 'defaultCodec': defaultCodec!.name,
  };

  @override
  String toString() =>
      'VideoConfig(id: $id, ${width}x$height @ ${fps}fps, $durationInFrames frames)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoConfig &&
          other.id == id &&
          other.width == width &&
          other.height == height &&
          other.fps == fps &&
          other.durationInFrames == durationInFrames;

  @override
  int get hashCode => Object.hash(id, width, height, fps, durationInFrames);
}
