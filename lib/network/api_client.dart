import 'package:hive/hive.dart';
import 'package:dio/dio.dart';

import '../config/constant.dart';
import '../model/student.dart';
import '../model/youtube_embed.dart';
import '../tool/format.dart';

class ApiClient {
  static Dio _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
    ),
  );

  static Future<Student> getStudent(
    String key, {
    bool reset = false,
  }) async {
    Box box = await Hive.openBox('student');
    if (reset) await box.delete(key.toLowerCase());
    String data = box.get(key.toLowerCase());
    if (data == null) {
      Response response = await _dio.get(
        Constant.baseUrl,
        queryParameters: <String, dynamic>{
          'version': Constant.version,
          'q': key,
        },
      );
      data = '${response.data}'.encode();
      await box.put(key, data);
    }
    await box.close();
    return Student.fromJson(data.decode());
  }

  static Future<YoutubeEmbed> getVideoInfo(String id) async {
    Box box = await Hive.openBox('video_info');
    String data = box.get(id);
    if (data == null) {
      Response response = await _dio.get(
        Constant.embedUrl,
        queryParameters: {
          'url': 'https://www.youtube.com/watch?v=$id',
        },
      );
      data = '${response.data}'.encode();
      await box.put(id, data);
    }
    await box.close();
    return YoutubeEmbed.fromJson(data.decode());
  }

  static Future<bool> sendReport(String text) async {
    Response response = await _dio.get(
      Constant.baseUrl,
      queryParameters: <String, String>{
        'version': Constant.version,
        'report': text,
      },
    );
    return response.statusCode == 200;
  }
}
