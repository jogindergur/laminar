import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';
import 'package:share_plus/share_plus.dart';

import 'gallery_screen.dart';

class PlayerScreen extends StatelessWidget {
  final CompositionEntry entry;
  const PlayerScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return LaminarPlayer(
      title: entry.title,
      icon: entry.icon,
      accent: entry.accent,
      config: VideoConfig(
        id: entry.id,
        // Default preview base size. LaminarPlayer scales output dynamically via export quality dropdown.
        width: 1920,
        height: 1080,
        fps: entry.fps,
        durationInFrames: entry.durationInFrames,
        download: entry.download,
      ),
      component: (ctx) => entry.composition,
      onExportSuccess: (outputPath) async {
        if (!kIsWeb) {
          // ignore: deprecated_member_use
          await Share.shareXFiles([XFile(outputPath)], text: 'Exported Laminar Video');
        }
      },
    );
  }
}
