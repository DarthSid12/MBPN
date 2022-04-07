// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';

import 'package:caller_app/screens/mainScreens/newConversation.dart';
import 'package:caller_app/variables/colors.dart';
import 'package:caller_app/widgets/numberBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pusher_client/pusher_client.dart';

import '../../providers/callProvider.dart';
import '/models/CompanyModel.dart';
import '/models/UserModel.dart';
import '/providers/apiProvider.dart';

class MessagePage extends StatefulWidget {
  UserModel userModel;
  MessagePage({Key? key, required this.userModel}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late CompanyModel selected;
  List<Widget> messagesWidgetList = <Widget>[];
  List<Widget> numberBoxRow = [];
  bool loading = false;
  @override
  void initState() {
    print("Init");
    super.initState();
    messagesWidgetList = [
      // ContactIconTile(number: '+1 (832) 724-8577', time: '(6:33pm)')
    ];
    initPusherClient();
    buildSelected();
  }

  buildSelected() async {
    loading = true;
    setState(() {});
    print("Build selected from messagePage");
    Map response =
        jsonDecode(await ApiProvider.whoAmI(widget.userModel.bearerToken));
    print("Build selected");
    print(response);
    widget.userModel.selected_company =
        response['data']['selected_company'].toString();
    buildNumberBoxRow(true);
    await getAllMessages();
    loading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void buildNumberBoxRow(bool buildSelected) {
    numberBoxRow = [];
    if (buildSelected) {
      selected = widget.userModel.companies
          .where((element) => element.uuid == widget.userModel.selected_company)
          .first;
    }

    for (CompanyModel company in widget.userModel.companies) {
      // print(company.name);
      numberBoxRow.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: NumberBoxWidget(
          name: company.name,
          number: company.phoneNumbers[0],
          selected: selected,
          onTap: (label) async {
            print("On tap");
            loading = true;
            setState(() {});
            if (selected != company) {
              selected = company;
              buildNumberBoxRow(false);

              setState(() {});
              String value = await ApiProvider.switchCompany(
                  widget.userModel.bearerToken, company.uuid);

              print(jsonDecode(value));
              await getAllMessages();
            }
            print("Done");
            loading = false;
            setState(() {});
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Message Page");
    return Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          backgroundColor: AppColors.lightGrey,
          elevation: 0,
          title: Text(
            "Messages",
            style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.blue,
          elevation: 12,
          onPressed: () async {
            await Navigator.push(
              context,
              PageTransition(
                  child: NewConversationPage(
                    from: selected.phoneNumbers.first,
                    userModel: widget.userModel,
                  ),
                  ctx: context,
                  duration: const Duration(milliseconds: 500),
                  type: PageTransitionType.fade),
            );
            buildSelected();
          },
          child: const Center(
            child: Icon(Icons.person_add),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(children: [
                SizedBox(
                  height: 70,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: numberBoxRow,
                    ),
                  ),
                ),
                // SizedBox(height: 30),
                // ListTile(title: Text("Hi"))
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: SingleChildScrollView(
                      child: Column(
                        children: messagesWidgetList,
                      ),
                    ))
              ]),
            ),
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
        ));
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
        buildSelected();
      }
    });
  }

  getAllMessages() async {
    Map result = jsonDecode(await ApiProvider.getMessages(
        widget.userModel.bearerToken, selected.phoneNumbers[0]));
    print(result);
    messagesWidgetList = [];
    if (result['status'] == 1) {
      for (Map contact in result['data']) {
        print("Contact");
        print(contact['messages'].length);
        messagesWidgetList.add(ContactIconTile(contact));
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget ContactIconTile(Map contact) {
    DateFormat messageDateFormat = DateFormat(
      "yyyy-MM-ddTkk:mm:ss",
    );
    contact['updated_at'] = messageDateFormat.format(
      messageDateFormat
          .parseUTC(contact['updated_at'].toString().substring(0, 19))
          .toLocal()
          .add(Duration(hours: 2)),
    );
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1, color: AppColors.darkGrey.withOpacity(0.4)))),
      child: ListTile(
          onTap: () async {
            await Navigator.pushNamed(context, '/chat', arguments: {
              'user': widget.userModel,
              "contact": contact,
              "phone": selected
            });
            print("Returned from chat");
            getAllMessages();
          },
          title: Text(
            CallProvider.formatNumber(contact['title']
                .toString()
                .replaceAll(selected.phoneNumbers[0], '')
                .replaceAll(',', '')
                .trim()),
            style: TextStyle(
                color: AppColors.lightestGrey,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.mail_outline, color: AppColors.orange),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightestGrey,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Icon(
                Icons.person,
                color: AppColors.blue,
                size: 24,
              ),
            ),
          ),
          // trailing: Icon(Icons.phone, color: AppColors.green),
          subtitle: Text(
            DateFormat('d MMM').format(
                  DateFormat("yyyy-MM-dd")
                      .parse(contact['updated_at'].toString().substring(0, 10)),
                ) +
                ', ' +
                DateFormat(DateFormat.HOUR_MINUTE).format(
                  DateFormat("kk:mm:ss").parse(
                      contact['updated_at'].toString().substring(11, 19)),
                ),
            style: TextStyle(color: AppColors.lightestGrey, fontSize: 11),
          )),
    );
  }
}
