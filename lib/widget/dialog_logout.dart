import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_route.dart';
import '../provider/account_provider.dart';

class DialogLogout extends StatelessWidget {
  final BuildContext context;

  DialogLogout(
    this.context, {
    Key key,
  }) : super(key: key);

  void show() {
    showDialog(
      context: context,
      builder: (BuildContext context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Are you sure want to sign out?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => AppRoute.pop(),
          child: Text('NO'),
        ),
        TextButton(
          onPressed: () async {
            await context.read<AccountProvider>().signOut();
            AppRoute.pushRemoveUntil(AppRoute.loginPage);
          },
          child: Text('YES'),
        ),
      ],
    );
  }
}
