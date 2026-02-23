import 'dart:ui' as ui;
import 'dart:isolate';
import 'dart:typed_data';

void main() async {
  await Isolate.run(() async {
      print("Isolate started!");
      try {
        final b = Uint8List(100*100*4);
        ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
          await ui.ImmutableBuffer.fromUint8List(b),
          width: 100,
          height: 100,
          pixelFormat: ui.PixelFormat.rgba8888,
        );
        ui.Codec codec = await descriptor.instantiateCodec();
        ui.FrameInfo frame = await codec.getNextFrame();
        final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
        print("Success! PNG Size: ${byteData?.lengthInBytes}");
      } catch (e) {
        print("Isolate Error: $e");
      }
  });
}
