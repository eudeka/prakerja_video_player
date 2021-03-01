import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AccountProvider extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleAuthProvider _authProvider = GoogleAuthProvider();

  User get user => this._auth.currentUser;

  void checkLogin() => notifyListeners();

  Future<void> signIn() async {
    await this._auth.signInWithRedirect(_authProvider);
    notifyListeners();
  }

  Future<void> signOut() async {
    await this._auth.signOut();
    notifyListeners();
  }
}
