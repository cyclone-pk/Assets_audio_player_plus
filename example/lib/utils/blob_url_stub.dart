import 'dart:typed_data';

String createBlobUrl(Uint8List bytes, String mimeType) {
  throw UnsupportedError('createBlobUrl is only available on web.');
}

void revokeBlobUrl(String url) {}
