import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<String> downloadToLocal({
  required String url,
  required String fileName,
  required void Function(int received, int total) onProgress,
}) async {
  final tempDir = await getTemporaryDirectory();
  final savePath = '${tempDir.path}/$fileName';
  final response = await Dio().get<List<int>>(
    url,
    onReceiveProgress: onProgress,
    options: Options(responseType: ResponseType.bytes),
  );
  final file = File(savePath);
  await file.writeAsBytes(response.data!);
  return savePath;
}
