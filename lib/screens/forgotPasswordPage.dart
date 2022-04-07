import 'package:flutter/material.dart';

import '../variables/colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGrey,
      body: Padding(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Forgot Password",
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Please enter your registered email and a new pin will be sent to use when registering",
              style: TextStyle(
                color: AppColors.lightestGrey,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13.0),
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
                      hintStyle: TextStyle(color: AppColors.lightestGrey)),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.orange),
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 24),
                    child: Text(
                      "SEND",
                      style: TextStyle(color: AppColors.white, fontSize: 20),
                    )),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Remember Password?",
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
    );
  }
}
