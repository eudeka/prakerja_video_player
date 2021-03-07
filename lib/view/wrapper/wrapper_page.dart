import 'package:flutter/material.dart';

import '../../config/app_route.dart';
import '../../config/constant.dart';

class WrapperPage extends StatefulWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  WrapperPage({
    Key key,
    @required this.lightTheme,
    @required this.darkTheme,
    @required this.themeMode,
  }) : super(key: key);

  @override
  _WrapperPageState createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRoute.navigatorKey,
      onGenerateRoute: AppRoute.onGenerateRoute,
      builder: (BuildContext context, Widget child) => Material(
        child: child,
      ),
      title: Constant.name,
      theme: widget.lightTheme,
      darkTheme: widget.darkTheme,
      themeMode: widget.themeMode,
    );
  }
}
