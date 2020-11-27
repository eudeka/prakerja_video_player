// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'view/home/home_page.dart';

Future<void> main() async {
  await Hive.initFlutter();
  if (kIsWeb) for (var e in querySelectorAll(".load")) e.remove();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      title: 'Eudeka Indonesia (beta)',
    );
  }
}
