import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'dart:typed_data';

void main() {
  final outData = Uint8List.fromList([1, 2, 3, 4]);
  final jsArray = outData.toJS;
  final part = jsArray as JSAny;
  final parts = [part].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: 'video/mp4'));
  print("Blob size: ${blob.size}");
}
