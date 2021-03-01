import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_route.dart';
import '../../provider/account_provider.dart';
import '../../widget/google_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Timer _timer;

  AccountProvider get _account => context.read<AccountProvider>();

  Future<void> _initialize() async {
    await Future.delayed(
      Duration(
        seconds: 4,
      ),
    );
    _account.checkLogin();
    _timer = Timer.periodic(
      Duration(
        seconds: 1,
      ),
      (Timer timer) => _account.checkLogin(),
    );
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GoogleButton(
            onSuccess: () => AppRoute.pushRemoveUntil(AppRoute.homePage),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: GestureDetector(
              child: Text('Already login?'),
              onTap: _account.checkLogin,
            ),
          ),
        ],
      ),
    );
  }
}
