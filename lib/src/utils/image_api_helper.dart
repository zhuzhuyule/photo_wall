import 'dart:convert';
import 'package:exif/exif.dart';
import 'package:http/http.dart' as http;
import 'package:photo_wall/src/const.dart';

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
        toast('Failed to load files.${response.statusCode}');
        return FutureResult('Failed to load files.${response.statusCode}', []);
      }
    } catch (e) {
      toast('Failed to load files.$e');
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

Future<Map<String, dynamic>?> getImageInfo(String url) async {
  final response = await http.get(Uri.parse(url));

  var imageBytes = response.bodyBytes;
  var data = await readExifFromBytes(imageBytes);
  if (data.isEmpty) {
    print("No EXIF information found");
    return null;
  }

  double convertToDecimal(List<num> list) {
    return list[0] + list[1] / 60 + list[2] / 3600;
  }

  double parseNumberList(IfdTag? value) {
    if (value == null) {
      return 0.0;
    }
    var matchResult = RegExp(r'\[(\w*), (\w*), (\w.*)/(\w.*)\]')
        .firstMatch(value.toString())!;
    return convertToDecimal([
      int.parse(matchResult.group(1)!),
      int.parse(matchResult.group(2)!),
      int.parse(matchResult.group(3)!) / int.parse(matchResult.group(4)!)
    ]);
  }

  final latitude = parseNumberList(data['GPS GPSLatitude']);
  final longitude = parseNumberList(data['GPS GPSLongitude']);
  final locationInfo = await getLocationInfo(longitude, latitude);

  return {
    'time': data['EXIF DateTimeOriginal'].toString(),
    'phone':
        '${data['Image Make']} ${data['Image Model']}'.replaceAll('[]', ''),
    'province': '${locationInfo['regeocode']?['addressComponent']?['province']}'
        .replaceAll('[]', ''),
    'city': '${locationInfo['regeocode']?['addressComponent']?['city']}'
        .replaceAll('[]', ''),
    'district': '${locationInfo['regeocode']?['addressComponent']?['district']}'
        .replaceAll('[]', ''),
  };
}

// {
//     "status": "1",
//     "regeocode": {
//         "addressComponent": {
//             "city": "西安市",
//             "province": "陕西省",
//             "adcode": "610113",
//             "district": "雁塔区",
//             "streetNumber": {
//                 "number": "49号",
//                 "direction": "东北",
//                 "street": "科技西路"
//             },
//             "country": "中国",
//             "township": "漳浒寨街道"
//         }
//     }
// }

Future<Map<String, dynamic>> getLocationInfo(
    double longitude, double latitude) async {
  const String apiKey = 'f7d40927ba4d64fb91ebe2bb9cda0995';
  final String url =
      'https://lbs.amap.com/_AMapService/v3/geocode/regeo?key=$apiKey&s=rsv3&language=zh_cn&location=$longitude,$latitude&sdkversion=1.4.24';

  try {
    final response = await http.get(Uri.parse(url),
        headers: {'referer': 'https://lbs.amap.com/tools/picker'});
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load location information');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
