import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminar/src/core/composition_provider.dart';
import 'package:laminar/src/core/series.dart';
import 'package:laminar/src/models/video_config.dart';

void main() {
  group('Series Widget', () {
    const config = VideoConfig(id: 'test_series', width: 1920, height: 1080, fps: 30, durationInFrames: 100);

    Widget buildSeriesEnv(int currentFrame, Series series) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: CompositionProvider(config: config, frame: currentFrame, child: series),
      );
    }

    final seriesWidget = Series(
      sequences: [
        SeriesSequence(durationInFrames: 30, child: Container(key: const Key('child1'))),
        SeriesSequence(durationInFrames: 20, child: Container(key: const Key('child2'))),
        SeriesSequence(durationInFrames: 50, child: Container(key: const Key('child3'))),
      ],
    );

    testWidgets('renders first sequence initially', (tester) async {
      await tester.pumpWidget(buildSeriesEnv(0, seriesWidget));
      expect(find.byKey(const Key('child1')), findsOneWidget);
      expect(find.byKey(const Key('child2')), findsNothing);
      expect(find.byKey(const Key('child3')), findsNothing);
    });

    testWidgets('renders second sequence at offset', (tester) async {
      await tester.pumpWidget(buildSeriesEnv(35, seriesWidget));
      expect(find.byKey(const Key('child1')), findsNothing);
      expect(find.byKey(const Key('child2')), findsOneWidget);
      expect(find.byKey(const Key('child3')), findsNothing);
    });

    testWidgets('renders third sequence correctly', (tester) async {
      await tester.pumpWidget(buildSeriesEnv(80, seriesWidget));
      expect(find.byKey(const Key('child1')), findsNothing);
      expect(find.byKey(const Key('child2')), findsNothing);
      expect(find.byKey(const Key('child3')), findsOneWidget);
    });
  });
}
