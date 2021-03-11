import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/quiz.dart';
import '../../provider/task_provider.dart';
import '../../widget/app_scaffold.dart';
import 'task_content.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  bool _onLoad = true;
  List<Quiz> _listQuiz = <Quiz>[];

  TaskProvider get _provider => context.read<TaskProvider>();

  Future<void> _initialize() async {
    _listQuiz = await _provider.loadLastQuiz();
    setState(() => _onLoad = false);
  }

  Widget _child() {
    if (_onLoad) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator.adaptive(),
      );
    }
    if (_listQuiz.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No Task'),
      );
    }
    return TaskContent(listQuiz: _listQuiz);
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: _child(),
      ),
    );
  }
}
