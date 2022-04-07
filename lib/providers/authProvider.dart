import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  static void logOut(BuildContext context) async {
    (await SharedPreferences.getInstance()).clear();
    await Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
