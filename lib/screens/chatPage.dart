// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:caller_app/models/CompanyModel.dart';
import 'package:caller_app/models/UserModel.dart';
import 'package:caller_app/providers/apiProvider.dart';
import 'package:caller_app/variables/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pusher_client/pusher_client.dart';

import '../providers/callProvider.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> contact;
  final UserModel userModel;
  final CompanyModel senderPhone;
  final bool updateTime;
  const ChatPage({
    Key? key,
    required this.userModel,
    required this.contact,
    required this.senderPhone,
    this.updateTime = true,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // List<Widget> messageWidgetList = <Widget>[];
  FocusNode messageFocusNode = FocusNode();
  DateFormat messageDateFormat = DateFormat(
    "yyyy-MM-ddTkk:mm:ss",
  );
  TextEditingController messageController = TextEditingController();
  List<XFile> xFilesImages = [];
  bool loading = false;
  String messageTo = '';
  List<Map<String, dynamic>> messagesList = [];
  String lastDate = '';
  @override
  void initState() {
    super.initState();
    initPusherClient();
    messageTo = widget.contact['title']
        .toString()
        .replaceAll(widget.senderPhone.phoneNumbers.first, '')
        .replaceAll(',', '')
        .replaceAll(' ', '');
    buildChats();
  }

  @override
  Widget build(BuildContext context) {
    print("hi");
    print(messagesList.length);
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          CallProvider.formatNumber(messageTo),
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.only(
                  top: 12, left: 12, right: 12, bottom: 70),
              child: GroupedListView<Map, dynamic>(
                  elements: messagesList,
                  order: GroupedListOrder.DESC,
                  reverse: true,
                  itemComparator: (a, b) {
                    DateTime firstDate = messageDateFormat
                        .parse(a['created_at'].toString().substring(0, 19));
                    DateTime secondDate = messageDateFormat
                        .parse(b['created_at'].toString().substring(0, 19));
                    return firstDate.compareTo(secondDate);
                  },
                  groupSeparatorBuilder: (element) {
                    print("Group seperator");
                    print(element);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                          child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.darkGrey,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(
                                DateFormat("yyyy-MM-dd").parse(element)),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )),
                    );
                  },
                  // useStickyGroupSeparators: true,
                  groupBy: (Map element) =>
                      element['created_at'].toString().substring(0, 10),
                  // addAutomaticKeepAlives: true,
                  itemBuilder: (ctx, _message) {
                    print(_message['created_at']);

                    if (_message['sender']['phone_number'] ==
                        widget.senderPhone.phoneNumbers[0]) {
                      print("Sent message");
                      return SentMessage(_message as Map<String, dynamic>,
                          senderPhone: widget.senderPhone);
                    } else {
                      return RecievedMessage(_message as Map<String, dynamic>,
                          messageTo: messageTo);
                    }
                  })),
          SentMessageField(context),
          if (loading)
            Container(
              height: double.infinity,
              width: double.infinity,
              color: AppColors.lightGrey.withOpacity(0.3),
              child: Center(
                  child: SpinKitChasingDots(
                color: AppColors.blue,
              )),
            )
        ],
      ),
    );
  }

  void initPusherClient() {
    PusherClient pusherClient = PusherClient(
      "3283525c429951b8738d",
      PusherOptions(
        cluster: 'us3',
        auth: PusherAuth('https://gbpn.com/api/broadcasting/auth', headers: {
          "Authorization": "Bearer " + widget.userModel.bearerToken
        }),
      ),
    );
    Channel pusherChannel =
        pusherClient.subscribe('private-conversations.18326328103');
    pusherChannel.bind('message-event', (event) {
      print("message event");

      if (event != null) {
        Map<String, dynamic> _message = jsonDecode(event.data!)['data'];
        print(_message['created_at']);
        _message['created_at'] = messageDateFormat.format(messageDateFormat
            .parseUtc(_message['created_at'].toString().substring(0, 19))
            .toLocal()
            .add(Duration(hours: 2)));
        messagesList.add(_message);
        // print(_message);
        Map<String, dynamic> _contact = widget.contact;
        _contact['messages'] = messagesList;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    userModel: widget.userModel,
                    contact: _contact,
                    senderPhone: widget.senderPhone,
                    updateTime: false)));
        setState(() {});
      }
    });
  }

  void buildChats() {
    messagesList = [];
    for (Map<String, dynamic> message in widget.contact['messages']) {
      print("Build chat");
      print(message);
      if (widget.updateTime) {
        message['created_at'] = messageDateFormat.format(messageDateFormat
            .parseUtc(message['created_at'].toString().substring(0, 19))
            .toLocal()
            .add(Duration(hours: 2)));
      }
      messagesList.add(message);
    }

    // messagesList.sort((a, b) {
    //   DateTime firstDate =
    //       messageDateFormat.parse(a['created_at'].toString().substring(0, 19));
    //   DateTime secondDate =
    //       messageDateFormat.parse(b['created_at'].toString().substring(0, 19));
    //   return secondDate.compareTo(firstDate);
    // });
    // setState(() {});
  }

  Align SentMessageField(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (xFilesImages.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: xFilesImages.map<Widget>((element) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SizedBox(
                        height: 100,
                        width: 80,
                        child: Image.file(
                          File(element.path),
                          frameBuilder:
                              (ctx, child, frame, wasSynchronouslyLoaded) {
                            return SizedBox(
                              width: MediaQuery.of(ctx).size.width,
                              height: MediaQuery.of(ctx).size.height,
                              child: Stack(
                                children: [
                                  child,
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.white,
                                      ),
                                      child: FittedBox(
                                        child: GestureDetector(
                                            onTap: () {
                                              xFilesImages.remove(element);
                                              setState(() {});
                                            },
                                            child: const Icon(Icons.cancel)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 5),
          SizedBox(
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
              child: Container(
                // height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.darkGrey,
                ),
                child: TextFormField(
                  // expands: true,
                  style: TextStyle(color: AppColors.white),
                  focusNode: messageFocusNode,
                  controller: messageController,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(right: 8, left: 8, top: 14),
                      prefixIcon: InkWell(
                        onTap: () async {
                          if (!(await Permission.camera.isGranted)) {
                            await Permission.camera.request();
                            await Permission.photos.request();
                          }
                          ImagePicker _picker = ImagePicker();
                          xFilesImages = await _picker.pickMultiImage() ?? [];

                          setState(() {});
                        },
                        child: Icon(
                          Icons.attachment,
                          size: 34,
                          color: AppColors.lightestGrey,
                        ),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () async {
                          if (messageController.text.isNotEmpty ||
                              xFilesImages.isNotEmpty) {
                            messageFocusNode.unfocus();
                            setState(() {});
                            print("Sent button clicked");
                            ApiProvider.sendMessage(
                                widget.userModel.bearerToken,
                                widget.senderPhone.phoneNumbers.first,
                                messageTo,
                                messageController.text,
                                xFilesImages);

                            messageController.text = '';
                            xFilesImages = [];
                            setState(() {});
                          }
                        },
                        child: const Icon(
                          Icons.send,
                          size: 30,
                          color: Color(0xFF004b77),
                        ),
                      ),
                      fillColor: AppColors.lightGrey,
                      hintText: "Enter message...",
                      hintStyle: TextStyle(color: AppColors.lightestGrey)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SentMessage extends StatefulWidget {
  final Map<String, dynamic> message;
  final CompanyModel senderPhone;
  const SentMessage(this.message, {Key? key, required this.senderPhone})
      : super(key: key);

  @override
  State<SentMessage> createState() => _SentMessageState();
}

class _SentMessageState extends State<SentMessage> {
  late Map<String, dynamic> message;
  @override
  void initState() {
    super.initState();
    message = widget.message;
  }

  @override
  Widget build(BuildContext context) {
    if (message['media_urls'] != null && message['media_urls'].isNotEmpty) {
      String imageUrl = '';
      try {
        imageUrl = message['media_urls'][0]['url'];
      } catch (e) {
        if (e.runtimeType == NoSuchMethodError) {
          imageUrl = message['media_urls']['1']['url'];
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF004b77),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    child: Column(
                      children: [
                        Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.4,
                              // maxWidth: MediaQuery.of(context).size.width * 0.4,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/photoView',
                                    arguments: {
                                      'number':
                                          widget.senderPhone.phoneNumbers.first,
                                      'image': imageUrl
                                    });
                              },
                              child: Image.network(
                                imageUrl,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width * 0.4,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Center(
                                      child: SpinKitChasingDots(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )),
                        if (message['message'] != null)
                          const SizedBox(
                            height: 12,
                          ),
                        // message['message'] == null
                        //     ? Container()
                        Text(
                          message['message'] ?? "",
                          maxLines: null,
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                // minWidth: MediaQuery.of(context).size.width * 0.2,
                minHeight: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF004b77),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Builder(builder: (context) {
                      try {
                        return Text(
                          (message['message'] ?? "Error"),
                          maxLines: null,
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        );
                      } catch (e) {
                        return Text(
                          message['message']['message'] ?? "Error",
                          maxLines: null,
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        );
                      }
                    }),
                  ),
                  Text(
                    DateFormat(DateFormat.HOUR_MINUTE).format(
                        DateFormat("kk:mm").parse(message['created_at']
                            .toString()
                            .substring(11, 16))),
                    style: TextStyle(color: AppColors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class RecievedMessage extends StatefulWidget {
  Map<String, dynamic> message;
  String messageTo;
  RecievedMessage(this.message, {Key? key, required this.messageTo})
      : super(key: key);

  @override
  State<RecievedMessage> createState() => _RecievedMessageState();
}

class _RecievedMessageState extends State<RecievedMessage> {
  late Map<String, dynamic> message;
  @override
  void initState() {
    message = widget.message;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (message['media_urls'] != null && message['media_urls'].isNotEmpty) {
      String imageUrl = '';
      try {
        imageUrl = message['media_urls'][0]['url'];
      } catch (e) {
        if (e.runtimeType == NoSuchMethodError) {
          imageUrl = message['media_urls']['1']['url'];
        }
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.darkGrey,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                          maxWidth: MediaQuery.of(context).size.width * 0.4),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/photoView',
                              arguments: {
                                'number': widget.messageTo,
                                'image': imageUrl
                              });
                        },
                        child: Image.network(
                          imageUrl,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return SizedBox(
                              height: MediaQuery.of(context).size.width * 0.4,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Center(
                                child: SpinKitChasingDots(
                                  color: AppColors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                  if (message['message'] != null)
                    const SizedBox(
                      height: 12,
                    ),
                  Text(
                    message['message'] ?? "",
                    maxLines: null,
                    style: TextStyle(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.darkGrey,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      message['message'] ?? "Error",
                      maxLines: null,
                      style: TextStyle(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat(DateFormat.HOUR_MINUTE).format(
                        DateFormat("kk:mm").parse(message['created_at']
                            .toString()
                            .substring(11, 16))),
                    style: TextStyle(color: AppColors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class TimeBox extends StatefulWidget {
  final String lastDate;
  const TimeBox({Key? key, required this.lastDate}) : super(key: key);

  @override
  State<TimeBox> createState() => _TimeBoxState();
}

class _TimeBoxState extends State<TimeBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.darkGrey,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
              .format(DateFormat("yyyy-MM-dd").parse(widget.lastDate)),
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
