import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'provider/account_provider.dart';
import 'provider/task_provider.dart';
import 'provider/theme_provider.dart';
import 'provider/video_provider.dart';
import 'view/wrapper/wrapper_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp();
  runApp(
    MainApp(),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ThemeProvider>(
          create: (BuildContext context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AccountProvider>(
          create: (BuildContext context) => AccountProvider(),
        ),
        ChangeNotifierProvider<VideoProvider>(
          create: (BuildContext context) => VideoProvider(),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (BuildContext context) => TaskProvider(),
        ),
      ],
      builder: (BuildContext context, Widget child) {
        ThemeProvider theme = context.watch<ThemeProvider>();
        return WrapperPage(
          lightTheme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.mode,
        );
      },
    );
  }
}
