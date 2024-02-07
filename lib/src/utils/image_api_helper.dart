import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageApiHelper {
  static final ImageApiHelper _instance = ImageApiHelper._internal();

  factory ImageApiHelper() {
    return _instance;
  }

  static const String baseUrl = 'http://192.168.3.234:5200';
  static const String apiUrl = '/api/fs/list';
  final String path = "/";

  late List<String> list = [];

  ImageApiHelper._internal();

  Future<FutureResult<List<TFileInfo>>> getDirFiles(String? name) async {
    try {
      final newPath = ((name == '' || name == null) ? path : '$path/$name')
          .replaceAll(RegExp('/+'), '/');

      final data = {'path': newPath};
      final response = await http.post(
        Uri.parse('$baseUrl$apiUrl'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var data = jsonData['data']['content'] as List;

        List<TFileInfo> audioFiles =
            data.map((json) => TFileInfo.fromJson(json)).toList();

        return FutureResult('', audioFiles);
      } else {
        return FutureResult('Failed to load files.${response.statusCode}', []);
      }
    } catch (e) {
      FutureResult('$e', []);
    }
    return FutureResult('Failed to load files', []);
  }

  String getFileLink(String path, TFileInfo fileInfo) {
    if (fileInfo.isDir) {
      return '';
    }
    return '$baseUrl/d$path/${fileInfo.name}?sign=${fileInfo.sign}';
  }
}

class FutureResult<T> {
  final String error;
  final T result;

  FutureResult(this.error, this.result);
}

class TFileInfo {
  final String name;
  final int size;
  final bool isDir;
  final DateTime modified;
  final String sign;
  final String thumb;
  final int type;

  TFileInfo({
    required this.name,
    required this.size,
    required this.isDir,
    required this.modified,
    required this.sign,
    required this.thumb,
    required this.type,
  });

  factory TFileInfo.fromJson(Map<String, dynamic> json) {
    return TFileInfo(
      name: json['name'],
      size: json['size'],
      isDir: json['is_dir'],
      modified: DateTime.parse(json['modified']),
      sign: json['sign'],
      thumb: json['thumb'],
      type: json['type'],
    );
  }
}
