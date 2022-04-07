import 'dart:convert';

import 'package:caller_app/variables/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/UserModel.dart';
import '../providers/apiProvider.dart';

class SplashScreen extends StatefulWidget {
  bool openMessage = false;
  SplashScreen({Key? key, required this.openMessage}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    await Firebase.initializeApp();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('credentials') == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Map creds = jsonDecode(prefs.getString('credentials')!);
      String body = await ApiProvider.login(creds['email'], creds['pass']);
      Map response = jsonDecode(body);
      UserModel user = UserModel(
        name: response['user']['name'],
        email: response['user']['email'],
        bearerToken: response['bearer_token'],
        appAuthToken: response['app_auth_token'],
      );
      if (widget.openMessage) {
        Navigator.pushReplacementNamed(
          context,
          '/root',
          arguments: {'user': user, 'page': "Messages"},
        );
        return;
      }
      Navigator.pushReplacementNamed(
        context,
        '/root',
        arguments: user,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: AppColors.darkGrey,
      child: SpinKitChasingDots(color: AppColors.blue),
    );
  }
}
