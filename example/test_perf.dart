// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter_test/flutter_test.dart';

// void main() async {
//   test('Benchmark PNG Encoding (4K)', () async {
//     print('Generating a 4K placeholder image...');

//     // Create a raw 4K image buffer
//     final width = 3840;
//     final height = 2160;
//     final rgbaBytes = Uint8List(width * height * 4);

//     // Fill it with some basic data so compression isn't entirely trivial (e.g., solid red)
//     for (int i = 0; i < rgbaBytes.length; i += 4) {
//       rgbaBytes[i] = 255; // R
//       rgbaBytes[i + 1] = 100; // G
//       rgbaBytes[i + 2] = 50; // B
//       rgbaBytes[i + 3] = 255; // A
//     }

//     ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
//       await ui.ImmutableBuffer.fromUint8List(rgbaBytes),
//       width: width,
//       height: height,
//       pixelFormat: ui.PixelFormat.rgba8888,
//     );

//     ui.Codec codec = await descriptor.instantiateCodec();
//     ui.FrameInfo frame = await codec.getNextFrame();
//     final uiImage = frame.image;

//     print('Testing Flutter Skia Native C++ PNG Encoder...');
//     final watch1 = Stopwatch()..start();
//     // Native flutter C++ encode
//     final pngDataNative = await uiImage.toByteData(format: ui.ImageByteFormat.png);
//     watch1.stop();
//     print('Native C++ Encoding took: ${watch1.elapsedMilliseconds}ms (${pngDataNative!.lengthInBytes} bytes)');

//     print('Testing Pure Dart `image` package Encoder...');
//     final watch2 = Stopwatch()..start();
//     // Image package encode
//     final imageDart = img.Image.fromBytes(
//       width: width,
//       height: height,
//       bytes: rgbaBytes.buffer,
//       order: img.ChannelOrder.rgba,
//     );
//     final pngBytesDart = img.encodePng(imageDart, level: 3);
//     watch2.stop();
//     print('Pure Dart `image` Encoding took: ${watch2.elapsedMilliseconds}ms (${pngBytesDart.length} bytes)');

//     final ratio = watch2.elapsedMilliseconds / watch1.elapsedMilliseconds;
//     print('RESULT: Pure Dart is ${ratio.toStringAsFixed(1)}x slower than Native Flutter.');
//   });
// }
