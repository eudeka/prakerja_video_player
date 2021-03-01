import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/account_provider.dart';

enum GoogleButtonType { SIGN_IN }

class GoogleButton extends StatelessWidget {
  final GoogleButtonType type;
  final VoidCallback onSuccess;

  GoogleButton({
    Key key,
    this.type = GoogleButtonType.SIGN_IN,
    this.onSuccess,
  }) : super(key: key);

  Future<void> _signIn(BuildContext context) async {
    await context.read<AccountProvider>().signIn();
    this.onSuccess?.call();
  }

  String get _text {
    switch (this.type) {
      case GoogleButtonType.SIGN_IN:
      default:
        return 'Sign in with Google';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => this._signIn(context),
      textColor: Colors.white,
      color: Color(0xff4285f4),
      padding: EdgeInsets.all(10.0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.white,
            child: Image.network(
              'images/google_logo.png',
              width: 24.0,
              height: 24.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(this._text),
          ),
        ],
      ),
    );
  }
}
