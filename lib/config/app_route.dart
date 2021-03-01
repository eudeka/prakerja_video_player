import 'package:flutter/material.dart';

import '../view/home/home_page.dart';
import '../view/login/login_page.dart';
import '../view/task/task_page.dart';
import '../view/unknown/unknown_page.dart';
import '../view/video/video_page.dart';

class AppRoute {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String homePage = '/';
  static const String loginPage = '/login';
  static const String videoPage = '/video';
  static const String taskPage = '/task';

  static NavigatorState get navigator => navigatorKey.currentState;

  static Route onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        switch (settings.name) {
          case homePage:
            return HomePage();
          case loginPage:
            return LoginPage();
          case videoPage:
            return VideoPage();
          case taskPage:
            return TaskPage();
          default:
            return UnknownPage();
        }
      },
      settings: settings,
    );
  }

  static void push(String target, [Object object]) {
    navigator.pushNamed(target, arguments: object);
  }

  static void pushReplacement(String target, [Object object]) {
    navigator.pushReplacementNamed(target, arguments: object);
  }

  static void pushRemoveUntil(String target, [Object object]) {
    navigator.pushNamedAndRemoveUntil(
      target,
      (Route route) => false,
      arguments: object,
    );
  }

  static void pop() => navigator.pop();
}
