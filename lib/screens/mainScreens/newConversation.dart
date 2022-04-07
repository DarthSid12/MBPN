import 'dart:convert';

import 'package:caller_app/models/UserModel.dart';
import 'package:caller_app/providers/apiProvider.dart';
import 'package:caller_app/variables/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewConversationPage extends StatefulWidget {
  final String from;
  final UserModel userModel;
  const NewConversationPage(
      {Key? key, required this.from, required this.userModel})
      : super(key: key);

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  TextEditingController numberController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  GlobalKey<FormState> numberKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.darkGrey,
        title: Text(
          "New conversation",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.lightGrey,
                ),
                child: Form(
                  key: numberKey,
                  child: TextFormField(
                    // expands: true,
                    style: TextStyle(color: AppColors.white),
                    keyboardType: TextInputType.phone,
                    // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: numberController,
                    validator: (String? value) {
                      if (value!.length < 10) {
                        return "Incorrect mobile number";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(5),
                        prefixIcon: Icon(
                          Icons.person,
                          color: AppColors.lightestGrey,
                        ),
                        fillColor: AppColors.lightGrey,
                        labelText: "Number",
                        labelStyle: TextStyle(color: AppColors.lightestGrey)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.lightGrey,
                ),
                child: TextFormField(
                  controller: messageController,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(color: AppColors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(5),
                      prefixIcon: Icon(
                        Icons.message,
                        color: AppColors.lightestGrey,
                      ),
                      fillColor: AppColors.lightGrey,
                      hintText: "Message",
                      hintStyle: TextStyle(color: AppColors.lightestGrey)),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topRight,
            ),
            GestureDetector(
              onTap: () async {
                if (numberKey.currentState!.validate()) {
                  Map response = jsonDecode(await ApiProvider.newConversation(
                      widget.userModel.bearerToken,
                      widget.from,
                      numberController.text,
                      messageController.text));
                  print(response);
                  Navigator.pop(context);
                }
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
                  "CREATE",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
