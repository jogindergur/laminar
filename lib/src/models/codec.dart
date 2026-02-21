/// Output codec / container format for a rendered video.
enum Codec {
  /// H.264 video in an MP4 container (widest compatibility).
  h264,

  /// H.265 / HEVC video in an MP4 container (better compression).
  h265,

  /// VP8 video in a WebM container.
  vp8,

  /// VP9 video in a WebM container.
  vp9,

  /// AV1 video in an MP4 container.
  av1,

  /// Animated GIF output (no audio).
  gif,

  /// ProRes video (high-quality mastering format).
  prores,

  /// Audio-only MP3 export.
  mp3,

  /// Audio-only AAC export.
  aac,

  /// Audio-only WAV export.
  wav,
}

/// Extension adding convenience helpers to [Codec].
extension CodecExtension on Codec {
  /// Returns the canonical file extension (without leading dot).
  String get extension {
    switch (this) {
      case Codec.h264:
      case Codec.h265:
      case Codec.av1:
      case Codec.prores:
        return 'mp4';
      case Codec.vp8:
      case Codec.vp9:
        return 'webm';
      case Codec.gif:
        return 'gif';
      case Codec.mp3:
        return 'mp3';
      case Codec.aac:
        return 'aac';
      case Codec.wav:
        return 'wav';
    }
  }

  /// Returns `true` if the codec produces a video (not audio-only) output.
  bool get isVideoCodec =>
      this != Codec.mp3 && this != Codec.aac && this != Codec.wav;
}
