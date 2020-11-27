import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../model/student.dart';
import '../../network/api_client.dart';
import '../../widget/base_scaffold.dart';
import 'home_courses.dart';
import 'home_not_found.dart';
import 'home_sign_in.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleSignIn _google = GoogleSignIn();
  GoogleSignInAccount _account;
  bool _loading = false;
  Student _student;

  void _signIn() async => await _google.signIn();

  void _signOut() async => await _google.signOut();

  void _getCourses({bool reset = false}) async {
    setState(() => _loading = true);
    _student = await ApiClient.getStudent(_account.email, reset: reset);
    setState(() => _loading = false);
  }

  void _initUser() async {
    _google.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      _account = account;
      if (_account != null) _getCourses();
      setState(() {});
    });
    setState(() => _loading = true);
    bool isLogin = await _google.isSignedIn();
    if (isLogin) await _google.signInSilently();
    setState(() => _loading = false);
  }

  @override
  void initState() {
    _initUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showAppBar: _account != null,
      title: 'Hello ${_account?.email ?? 'Unknown'}',
      body: Center(
        child: _account != null
            ? _loading
                ? CircularProgressIndicator()
                : _student.result.length == 0
                    ? HomeNotFound()
                    : HomeCourses(student: _student)
            : HomeSignIn(onPressed: _signIn),
      ),
      onRefresh: () => _getCourses(reset: true),
      onSignOut: _signOut,
    );
  }
}
