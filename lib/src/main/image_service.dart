import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ImageService extends ChangeNotifier {
  // ImageService(
  //     [this.baseUrl = 'http://192.168.3.234:5200',
  //     this.apiUrl = '/api/fs/list',
  //     this.path = "/Backup/D/homes"]);

  final String baseUrl = 'http://192.168.3.234:5200';
  final String apiUrl = '/api/fs/list';
  final String path = "/Backup/D/homes/Pengfei/DCIM/Camera";

  late List<String> list = [];

  Future<String> getUrl() async {
    if (list.isEmpty) {
      print('----geturl----');
      await getRootDir().then((files) async {
        print(files);
        for (var fileInfo in files) {
          await getDeepDir(path, fileInfo, 5);
        }
        notifyListeners();
      });
    }
    return list[0];
  }

  Future<List<TFileInfo>> getRootDir() async {
    try {
      var response =
          await http.post(Uri.parse('$baseUrl$apiUrl'), body: {path: path});
      print('$baseUrl$apiUrl');
      print(response.statusCode);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var data = jsonData['data']['content'] as List;

        List<TFileInfo> audioFiles =
            data.map((json) => TFileInfo.fromJson(json)).toList();
        return audioFiles;
      } else {
        throw Exception(
            'Failed to load audio files, status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Error: $e');
    }
  }

  Future<void> getDeepDir(String path, TFileInfo child,
      [int deepCount = 5]) async {
    final newPath = '$path/${child.name}';
    if (deepCount > 0 && list.length < 100) {
      if (child.isDir) {
        try {
          var response = await http
              .post(Uri.parse('$baseUrl$apiUrl'), body: {path: newPath});
          if (response.statusCode == 200) {
            var jsonData = json.decode(response.body);
            var data = jsonData['data']['content'] as List;
            List<TFileInfo> files =
                data.map((json) => TFileInfo.fromJson(json)).toList();

            for (var fileInfo in files) {
              getDeepDir(newPath, fileInfo, deepCount - 1);
            }
          }
        } catch (e) {
          throw Exception('Error: $e');
        }
      } else {
        list.add(getFileLink(newPath, child));
      }
    } else {
      notifyListeners();
    }
  }

  String getFileLink(String path, TFileInfo fileInfo) {
    if (fileInfo.isDir) {
      return '';
    }
    return '$baseUrl$path/${fileInfo.name}?sign=${fileInfo.sign}';
  }
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
