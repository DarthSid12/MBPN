import 'dart:convert';

import 'package:caller_app/models/UserModel.dart';
import 'package:caller_app/providers/apiProvider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../variables/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool obscureText = true;
  String firebaseToken = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void setListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      print("On notification message");
      print(notification.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("On notificatioan message opened app");
      Navigator.pushNamed(context, '/', arguments: true);
    });
  }

  @override
  void initState() {
    super.initState();
    setListeners();
    _firebaseMessaging
        .subscribeToTopic('all')
        .then((value) => print("Subscribed"));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: size.height * 0.55,
            width: size.width * 0.6,
            child: Center(
              child: Image.asset(
                'assets/images/loginBG.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            height: size.height * 0.45,
            color: AppColors.darkGrey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Login",
                      style: TextStyle(color: AppColors.white, fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.lightGrey,
                      ),
                      child: TextFormField(
                        // expands: true,
                        style: TextStyle(color: AppColors.white),
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(5),
                            prefixIcon: Icon(
                              Icons.email,
                              color: AppColors.lightestGrey,
                            ),
                            fillColor: AppColors.lightGrey,
                            hintText: "Email",
                            hintStyle:
                                TextStyle(color: AppColors.lightestGrey)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.lightGrey,
                      ),
                      child: TextFormField(
                        controller: passController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: obscureText,
                        style: TextStyle(color: AppColors.white),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(5),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.lightestGrey,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                obscureText = !obscureText;
                                setState(() {});
                              },
                              child: Icon(
                                obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.lightestGrey,
                              ),
                            ),
                            fillColor: AppColors.lightGrey,
                            hintText: "Password",
                            hintStyle:
                                TextStyle(color: AppColors.lightestGrey)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                  ),
                  InkWell(
                    onTap: () async {
                      String body = await ApiProvider.login(
                          emailController.text, passController.text);
                      Map response = jsonDecode(body);
                      if (response['success'] == false ||
                          response['success'] == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: AppColors.blue,
                            content: Text(
                              "Incorrect credentials",
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 16),
                            )));
                        return;
                      }
                      SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      await sharedPreferences.setString(
                          'credentials',
                          jsonEncode({
                            'email': emailController.text,
                            'pass': passController.text
                          }));

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1, milliseconds: 500),
                          backgroundColor: AppColors.blue,
                          content: Text(
                            "Login Succesful",
                            style:
                                TextStyle(color: AppColors.white, fontSize: 16),
                          )));

                      await Future.delayed(Duration(seconds: 2));
                      UserModel user = UserModel(
                        name: response['user']['name'],
                        email: response['user']['email'],
                        bearerToken: response['bearer_token'],
                        appAuthToken: response['app_auth_token'],
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        '/root',
                        arguments: user,
                      );
                    },
                    child: Container(
                      height: 40,
                      width: size.width * 0.3,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                          child: Text(
                        "SUBMIT",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      )),
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/forgotPass');
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppColors.lightestGrey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
