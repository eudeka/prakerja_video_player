import 'package:flutter/foundation.dart';

import '../model/quiz.dart';
import '../network/api_client.dart';

class TaskProvider extends ChangeNotifier {
  Map<String, List<Quiz>> _listQuiz = <String, List<Quiz>>{};
  String _lastCategory = '';
  List<QuizValue> _lastAnswer = <QuizValue>[];

  String getLastCategory() => _lastCategory;

  void setLastCategory(String category) => _lastCategory = category;

  List<QuizValue> get lastAnswer => _lastAnswer;

  void setLastAnswer(int index, String answer) {
    _lastAnswer[index].answer = answer;
    Quiz quiz = _listQuiz[_lastCategory][index];
    bool isCorrect = false;
    switch (quiz.correct.toUpperCase()) {
      case 'A':
        isCorrect = quiz.answerA == answer;
        break;
      case 'B':
        isCorrect = quiz.answerB == answer;
        break;
      case 'C':
        isCorrect = quiz.answerC == answer;
        break;
      case 'D':
        isCorrect = quiz.answerD == answer;
        break;
      default:
    }
    _lastAnswer[index].isCorrect = isCorrect;
    notifyListeners();
  }

  Future<void> sendAnswer(String email, List<QuizValue> value) async {
    Map<String, dynamic> json = <String, dynamic>{
      'email': email,
      'sku': _lastCategory,
      'result': value,
    };
    await ApiClient.sendQuizAnswer(json);
  }

  Future<List<Quiz>> loadLastQuiz() async {
    List<Quiz> listQuiz = await ApiClient.getListQuiz(_lastCategory);
    listQuiz.shuffle();
    listQuiz = listQuiz.take(15).toList();
    _lastAnswer = List<QuizValue>.from(
      listQuiz.map(
        (Quiz quiz) => QuizValue(
          number: quiz.number,
        ),
      ),
    );
    return _listQuiz[_lastCategory] = listQuiz;
  }
}
