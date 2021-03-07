import 'package:flutter/material.dart';

import '../../config/app_route.dart';
import '../../model/quiz.dart';

class TaskResult extends StatelessWidget {
  final List<QuizValue> listQuiz;

  TaskResult(
    this.listQuiz, {
    Key key,
  }) : super(key: key);

  int get _result {
    int score = listQuiz.where((QuizValue value) => value.isCorrect).length;
    score = ((score / listQuiz.length) * 100).toInt();
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Your Result'),
      content: Text(
        '$_result',
        style: TextStyle(
          fontSize: 24.0,
        ),
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => AppRoute.navigator.popUntil(
            ModalRoute.withName(AppRoute.homePage),
          ),
          child: Text('OK'),
        ),
      ],
    );
  }
}
