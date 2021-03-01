import 'package:flutter/material.dart';

import '../config/app_route.dart';

class AppDialog extends StatelessWidget {
  final BuildContext context;
  final String text;

  AppDialog({
    Key key,
    @required this.context,
    @required this.text,
  }) : super(key: key);

  Future<void> show() async {
    showDialog(
      context: this.context,
      builder: (BuildContext context) => this,
    );
    await Future.delayed(
      Duration(
        seconds: 4,
      ),
    );
    AppRoute.navigator.popUntil(
      ModalRoute.withName(
        ModalRoute.of(this.context).settings.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(this.text ?? ''),
      ),
    );
  }
}
