import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/blob_url_web.dart';

Future<String> downloadToLocal({
  required String url,
  required String fileName,
  required void Function(int received, int total) onProgress,
}) async {
  final response = await Dio().get<List<int>>(
    url,
    onReceiveProgress: onProgress,
    options: Options(responseType: ResponseType.bytes),
  );
  final bytes = Uint8List.fromList(response.data!);
  return createBlobUrl(bytes, 'audio/mpeg');
}
