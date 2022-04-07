import 'dart:convert';

import 'package:caller_app/models/UserModel.dart';
import 'package:caller_app/providers/apiProvider.dart';
import 'package:caller_app/providers/authProvider.dart';
import 'package:caller_app/variables/colors.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  UserModel userModel;
  ProfilePage({Key? key, required this.userModel}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.07,
            ),
            Center(
              child: Container(
                height: size.width * 0.2,
                width: size.width * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 73, 230, 112).withOpacity(0.2),
                ),
                child: Center(
                    child: Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 73, 230, 112),
                  size: 44,
                )),
              ),
            ),
            SizedBox(
              height: size.height * 0.07,
            ),
            Text(
              "Account Info:",
              style: TextStyle(
                  color: AppColors.lightestGrey, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.darkGrey,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    // expands: true,
                    enabled: false,
                    initialValue: widget.userModel.name,
                    style:
                        TextStyle(color: AppColors.lightestGrey, fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(6),
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.lightestGrey,
                        ),
                        fillColor: AppColors.darkGrey,
                        labelText: "Name:",
                        labelStyle: TextStyle(
                            color: AppColors.lightestGrey,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.darkGrey,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    // expands: true,
                    enabled: false,
                    initialValue: widget.userModel.email,
                    style:
                        TextStyle(color: AppColors.lightestGrey, fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(6),
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.lightestGrey,
                        ),
                        fillColor: AppColors.darkGrey,
                        labelText: "Email:",
                        labelStyle: TextStyle(
                            color: AppColors.lightestGrey,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.darkGrey,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    // expands: true,
                    enabled: false,
                    initialValue: widget.userModel.uuid,
                    style:
                        TextStyle(color: AppColors.lightestGrey, fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(6),
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.lightestGrey,
                        ),
                        fillColor: AppColors.darkGrey,
                        labelText: "UUID:",
                        labelStyle: TextStyle(
                            color: AppColors.lightestGrey,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Text(
              "Other Options",
              style: TextStyle(
                  color: AppColors.lightestGrey, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  AuthProvider.logOut(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text("Log Out",
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
