import 'dart:convert';

import 'package:caller_app/models/UserModel.dart';
import 'callPage.dart';
import 'messagesPage.dart';
import 'numpadPage.dart';
import 'profilePage.dart';
import 'voiceMailsPage.dart';
import 'package:flutter/material.dart';

import '/providers/apiProvider.dart';
import '/variables/colors.dart';

class RootPage extends StatefulWidget {
  UserModel userModel;
  String firstPage;
  RootPage({Key? key, required this.userModel, required this.firstPage})
      : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  String selected = 'Calls';
  late Widget screen = Container();
  @override
  void initState() {
    selected = widget.firstPage;
    switch (selected) {
      case 'Calls':
        screen = CallPage(
          userModel: widget.userModel,
        );
        break;
      case 'Messages':
        screen = MessagePage(
          userModel: widget.userModel,
        );
        break;
      case 'Voicemails':
        screen = VoiceMailsPage(
          userModel: widget.userModel,
        );
        break;
      case 'Profile':
        screen = ProfilePage(
          userModel: widget.userModel,
        );
        break;
      default:
        selected = "Calls";
        screen = CallPage(
          userModel: widget.userModel,
        );
        break;
    }
    updateProfile();
    super.initState();
  }

  void updateProfile() async {
    print("Build selected from root page");
    Map response =
        jsonDecode(await ApiProvider.whoAmI(widget.userModel.bearerToken));
    try {
      widget.userModel =
          widget.userModel.updateFromJson(response['data'], widget.userModel);
    } catch (e) {}
    print(widget.userModel.uuid);
    print(widget.userModel.companies);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // int index = 0;
    // TabController screensController = TabController(length: length, vsync: vsync)

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                int sensitivity = 12;
                if (details.delta.dx > sensitivity) {
                  switch (selected) {
                    case 'Messages':
                      selected = "Calls";
                      screen = CallPage(
                        userModel: widget.userModel,
                      );
                      break;
                    case 'Voicemails':
                      selected = "Messages";
                      screen = MessagePage(
                        userModel: widget.userModel,
                      );
                      break;
                    case 'Profile':
                      selected = "Voicemails";
                      screen = VoiceMailsPage(
                        userModel: widget.userModel,
                      );
                      break;
                  }
                }

                // Swiping in left direction.
                if (details.delta.dx < -sensitivity) {
                  switch (selected) {
                    case 'Calls':
                      selected = "Messages";
                      screen = MessagePage(
                        userModel: widget.userModel,
                      );
                      break;
                    case 'Messages':
                      selected = "Voicemails";
                      screen = VoiceMailsPage(
                        userModel: widget.userModel,
                      );
                      break;
                    case 'Voicemails':
                      selected = "Profile";
                      screen = ProfilePage(
                        userModel: widget.userModel,
                      );
                      break;
                  }
                }
                setState(() {});
              },
              child: AnimatedSwitcher(
                duration: Duration(
                  milliseconds: 500,
                ),
                child: screen,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: size.height * 0.13,
        width: size.width,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * 0.1,
                  width: size.width,
                  color: AppColors.darkGrey,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        NavBarItem(
                          Icons.call_outlined,
                          Icons.call,
                          'Calls',
                          () {
                            screen = CallPage(
                              userModel: widget.userModel,
                            );
                            setState(() {});
                          },
                        ),
                        NavBarItem(
                          Icons.email_outlined,
                          Icons.email,
                          'Messages',
                          () {
                            setState(() {
                              screen = MessagePage(
                                userModel: widget.userModel,
                              );
                            });
                          },
                        ),
                        SizedBox(
                          height: 30,
                          width: 50,
                        ),
                        NavBarItem(Icons.voicemail_outlined, Icons.voicemail,
                            'Voicemails', () {
                          print("Voicemails");
                          setState(() {
                            screen = VoiceMailsPage(
                              userModel: widget.userModel,
                            );
                          });
                        }),
                        NavBarItem(
                            Icons.person_outline, Icons.person, 'Profile', () {
                          print("Profile");
                          setState(() {
                            screen = ProfilePage(
                              userModel: widget.userModel,
                            );
                          });
                        }),
                      ]),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * 0.13,
                  width: size.width,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FloatingActionButton(
                      backgroundColor: AppColors.darkGreen,
                      onPressed: () {
                        selected = "Calls";
                        screen = NumPadPage(
                          userModel: widget.userModel,
                        );
                        setState(() {});
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Image.asset(
                            'assets/images/numpad.png',
                            height: 95,
                            width: 70,
                            fit: BoxFit.fill,
                            // width: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget NavBarItem(
      IconData icon, IconData selectedIcon, String label, Function onTap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              // print("Hello");
              selected = label;
              onTap();
            });
          },
          child: Container(
            height: 25,
            width: 55,
            decoration: BoxDecoration(
                color: AppColors.darkGrey,
                boxShadow: selected == label
                    ? [
                        BoxShadow(
                          color: AppColors.lightBlue.withOpacity(0.2),
                          blurRadius: 2,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
                gradient: selected == label ? LinearGradient(
                    // radius: 1,
                    colors: [AppColors.blue, AppColors.lightBlue]) : null,
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Icon(
                (selected == label ? selectedIcon : icon),
                color: selected == label
                    ? AppColors.white
                    // ? AppColors.lightBlue
                    : AppColors.lightestGrey,
                size: 22,
              ),
            ),
          ),
        ),
        // const SizedBox(
        //   height: 10,
        // ),
        // Text(
        //   label,
        //   style: TextStyle(color: AppColors.lightestGrey),
        // ),
      ],
    );
  }
}
