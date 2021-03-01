import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../config/constant.dart';
import '../model/quiz.dart';
import '../model/student.dart';
import '../model/youtube_embed.dart';
import '../tool/format.dart';

class ApiClient {
  static Dio _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      validateStatus: (int code) => code >= 200 && code <= 399,
    ),
  );

  static Future<List<Quiz>> getListQuiz(String category) async {
    Box box = await Hive.openBox('list_quiz');
    String data = box.get(category);
    if (data == null) {
      Response response = await _dio.get(
        Constant.quizUrl,
        queryParameters: <String, dynamic>{
          'category': category,
        },
      );
      data = response.data;
      await box.put(category, data);
    }
    if (data?.isEmpty ?? true) return <Quiz>[];
    return quizFromMap(data.decode());
  }

  static Future<bool> sendQuizAnswer(Map<String, dynamic> data) async {
    Response response = await _dio.post(
      Constant.quizUrl,
      queryParameters: data,
    );
    return response.statusCode >= 200 && response.statusCode <= 399;
  }

  static Future<Student> getStudent(
    String key, {
    bool reset = false,
  }) async {
    Box box = await Hive.openBox('student');
    if (reset) await box.delete(key.toLowerCase());
    String data = box.get(key.toLowerCase());
    if (data == null) {
      Response response = await _dio.get(
        Constant.studentUrl,
        queryParameters: <String, dynamic>{
          'version': Constant.version,
          'q': key,
        },
      );
      data = '${response.data}'.encode();
      await box.put(key, data);
    }
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
    return YoutubeEmbed.fromJson(data.decode());
  }

  static Future<bool> sendReport(String text) async {
    Response response = await _dio.get(
      Constant.studentUrl,
      queryParameters: <String, String>{
        'version': Constant.version,
        'report': text,
      },
    );
    return response.statusCode >= 200 && response.statusCode <= 399;
  }
}
