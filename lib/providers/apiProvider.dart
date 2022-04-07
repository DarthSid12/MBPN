import 'dart:convert';

import 'package:caller_app/variables/apiConfig.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ApiProvider {
  static Future<String> login(String email, String password) async {
    print("Before login");
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String firebaseToken = (await _firebaseMessaging.getToken()) ?? "Error";
    print("Firebase Token");
    print(firebaseToken);
    http.Response response = await http.post(Uri.parse(ApiConfig.login), body: {
      "email": email.trim(),
      "password": password.trim(),
      "token": firebaseToken
    });
    print(response.body);
    return response.body;
  }

  static Future<String> whoAmI(String token) async {
    print("Before whoAmI");
    http.Response response = await http.get(Uri.parse(ApiConfig.whoAmI),
        headers: {"Authorization": 'Bearer ' + token});
    print(response.body);
    return response.body;
  }

  static Future<String> getCalls(String token,
      {DateTimeRange? dateTimeRange}) async {
    String startDate = "2021-04-01";
    String endDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

    if (dateTimeRange != null) {
      startDate = DateFormat("yyyy-MM-dd").format(dateTimeRange.start);
      endDate = DateFormat("yyyy-MM-dd").format(dateTimeRange.end);
    }
    print(endDate);
    print("Before get calls");
    print(token);
    http.Response response = await http.get(
        Uri.parse(ApiConfig.getCalls +
            '?start_date=' +
            startDate +
            '&end_date=' +
            endDate),
        headers: {"Authorization": 'Bearer ' + token});
    print(response.body);
    return response.body;
  }

  static Future<String> getVoicemails(String token) async {
    print("Before get voicemails");
    http.Response response = await http.get(Uri.parse(ApiConfig.voicemails),
        headers: {"Authorization": 'Bearer ' + token});
    print(response.body);
    return response.body;
  }

  static Future<String> getCompany(String token, String uuid) async {
    print("Before get company");
    http.Response response = await http.post(
        Uri.parse(ApiConfig.getCompany + '/' + uuid),
        headers: {"Authorization": 'Bearer ' + token});
    // print(response.body);
    return response.body;
  }

  static Future<String> switchCompany(String token, String uuid) async {
    print(token);
    print("Before switch company");
    http.Response response = await http.post(
        Uri.parse(ApiConfig.switchCompany + '/' + uuid),
        headers: {"Authorization": 'Bearer ' + token});
    // print(response.statusCode);
    // print(response.m);
    return response.body;
  }

  static Future<String> newConversation(
      String token, String from, String to, String message) async {
    print(token);
    print(from);
    print(to);
    print(message);
    print("Before new conversation");
    http.Response response =
        await http.post(Uri.parse(ApiConfig.newConversation), headers: {
      "Authorization": 'Bearer ' + token,
    }, body: {
      "from": from,
      "to": to,
      "content": message,
    });
    // print(response.statusCode);
    // print(response.m);
    return response.body;
  }

  static Future<String> getMessages(String token, String phone) async {
    print("Before get Messages");
    http.Response response = await http.get(
        Uri.parse(ApiConfig.getMessages + '?phone_numbers[]=' + phone),
        headers: {"Authorization": 'Bearer ' + token});
    // print(response.body);
    return response.body;
  }

  static Future<String> sendMessage(String token, String from, String to,
      String content, List<XFile> images) async {
    Map<String, String> data = {};
    data['from'] = from;
    data['to'] = to;
    data['content'] = content;

    print("Before send message");
    var request =
        http.MultipartRequest("POST", Uri.parse(ApiConfig.sendMessage));
    request.headers.addAll({"Authorization": 'Bearer ' + token});
    request.fields.addAll(data);
    for (int i in List.generate(images.length, (index) => index)) {
      // data['files[' + i.toString() + ']'] = jsonEncode({
      //   "name": 'files' + i.toString(),
      //   "type": images[i].mimeType,
      //   "uri": images[i]
      // });
      print("Added file");
      request.files.add(await http.MultipartFile.fromPath(
          'files[' + i.toString() + ']', images[i].path,
          filename: 'files' + i.toString()));
    }
    http.StreamedResponse response = await request.send();
    var responsed = await http.Response.fromStream(response);
    print("Send message");
    print(responsed.body);
    print("Message sent");
    return responsed.body;
  }
}
