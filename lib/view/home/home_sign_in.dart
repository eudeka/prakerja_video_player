import 'package:flutter/material.dart';

import '../../config/constant.dart';

class HomeSignIn extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeSignIn({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      onPressed: this.onPressed,
      color: Colors.white,
      icon: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
        ),
        child: Image.network(
          Constant.googleLogo,
          fit: BoxFit.fill,
        ),
      ),
      label: Text('Sign in with Google'),
    );
  }
}
