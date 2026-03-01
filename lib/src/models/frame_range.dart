/// A closed (inclusive) range of frame indices to render.
///
/// Both [start] and [end] are zero-based frame indices.
/// Equivalent to Remotion's `frameRange` option.
class FrameRange {

  const FrameRange({required this.start, required this.end})
      : assert(start >= 0, 'start must be >= 0'),
        assert(end >= start, 'end must be >= start');

  /// A convenience constructor to render a single frame.
  const FrameRange.single(int frame) : this(start: frame, end: frame);
  /// First frame index to render (inclusive, 0-based).
  final int start;

  /// Last frame index to render (inclusive, 0-based).
  final int end;

  /// Total number of frames in this range.
  int get length => end - start + 1;

  /// Returns every frame index in this range as an iterable.
  Iterable<int> get frames sync* {
    for (int i = start; i <= end; i++) {
      yield i;
    }
  }

  @override
  String toString() => 'FrameRange($start–$end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrameRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}
