import 'package:flutter/material.dart';

import '../../config/app_route.dart';

class UnknownPage extends StatefulWidget {
  @override
  _UnknownPageState createState() => _UnknownPageState();
}

class _UnknownPageState extends State<UnknownPage> {
  @override
  void initState() {
    Future.delayed(
      Duration(seconds: 2),
    ).then(
      (_) => AppRoute.pushReplacement(AppRoute.homePage),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '404',
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.shortestSide / 3,
        ),
      ),
    );
  }
}
