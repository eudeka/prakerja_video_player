import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/quiz.dart';
import '../../provider/account_provider.dart';
import '../../provider/task_provider.dart';
import 'task_result.dart';

class TaskContent extends StatelessWidget {
  final List<Quiz> listQuiz;

  TaskContent({Key key, @required this.listQuiz}) : super(key: key);

  Widget _tile(int index, TaskProvider provider) {
    Quiz quiz = listQuiz[index];
    QuizValue value = provider.lastAnswer[index];
    String question = '${index + 1}. ${quiz.question}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: SelectableText(question),
          contentPadding: EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
        ),
        RadioListTile<String>(
          value: quiz.answerA,
          groupValue: value.answer,
          onChanged: (String answer) => provider.setLastAnswer(index, answer),
          title: SelectableText(quiz.answerA),
        ),
        RadioListTile<String>(
          value: quiz.answerB,
          groupValue: value.answer,
          onChanged: (String answer) => provider.setLastAnswer(index, answer),
          title: SelectableText(quiz.answerB),
        ),
        RadioListTile<String>(
          value: quiz.answerC,
          groupValue: value.answer,
          onChanged: (String answer) => provider.setLastAnswer(index, answer),
          title: SelectableText(quiz.answerC),
        ),
        RadioListTile<String>(
          value: quiz.answerD,
          groupValue: value.answer,
          onChanged: (String answer) => provider.setLastAnswer(index, answer),
          title: SelectableText(quiz.answerD),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AccountProvider, TaskProvider>(
      builder: (
        BuildContext context,
        AccountProvider account,
        TaskProvider task,
        Widget child,
      ) {
        return ListView.builder(
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.all(8.0),
          itemBuilder: (BuildContext context, int index) {
            if (index == listQuiz.length) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await task.sendAnswer(
                      account.user.email,
                      task.lastAnswer,
                    );
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => TaskResult(
                        task.lastAnswer,
                      ),
                      barrierDismissible: false,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('SUBMIT YOUR TASK'),
                  ),
                ),
              );
            }
            return Card(
              margin: EdgeInsets.all(8.0),
              child: _tile(index, task),
            );
          },
          itemCount: listQuiz.length + 1,
        );
      },
    );
  }
}
