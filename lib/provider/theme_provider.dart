import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  PageTransitionsTheme get _pageTransitions {
    return PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
      },
    );
  }

  ThemeData get lightTheme {
    ThemeData data = ThemeData.light();
    return data.copyWith(
      platform: TargetPlatform.fuchsia,
      pageTransitionsTheme: _pageTransitions,
    );
  }

  ThemeData get darkTheme {
    ThemeData data = ThemeData.dark();
    return data.copyWith(
      platform: TargetPlatform.fuchsia,
      pageTransitionsTheme: _pageTransitions,
    );
  }

  void change() {
    _mode = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
