import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:caller_app/models/UserModel.dart';
import 'package:caller_app/providers/apiProvider.dart';
import 'package:caller_app/variables/colors.dart';
import 'package:caller_app/widgets/numberBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../../providers/callProvider.dart';
import '/models/CompanyModel.dart';

class VoiceMailsPage extends StatefulWidget {
  UserModel userModel;
  VoiceMailsPage({Key? key, required this.userModel}) : super(key: key);

  @override
  State<VoiceMailsPage> createState() => _VoiceMailsPageState();
}

class _VoiceMailsPageState extends State<VoiceMailsPage> {
  late CompanyModel selected;
  List<Widget> voicemailWidgetList = <Widget>[];
  List<Widget> numberBoxRow = <Widget>[];
  bool loading = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    voicemailWidgetList = [
      // ContactIconTile({"number": '+1 (832) 724-8577', "time": '(6:33pm)'})
    ];
    buildSelected();
  }

  buildSelected() async {
    loading = true;
    setState(() {});
    Map response =
        jsonDecode(await ApiProvider.whoAmI(widget.userModel.bearerToken));
    // print("Build selected");
    // print(response);
    widget.userModel.selected_company =
        response['data']['selected_company'].toString();
    buildNumberBoxRow(true);
    await buildVoicemails();
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
            loading = true;
            setState(() {});
            if (selected != company) {
              selected = company;
              buildNumberBoxRow(false);
              setState(() {});
              String value = await ApiProvider.switchCompany(
                  widget.userModel.bearerToken, company.uuid);

              // print(jsonDecode(value));
              await buildVoicemails();
            }
            loading = false;
            setState(() {});
          },
        ),
      ));
    }
  }

  buildVoicemails() async {
    String lastDate = '';
    Map response = jsonDecode(
        await ApiProvider.getVoicemails(widget.userModel.bearerToken));
    // print(response);
    List voicemails = response['data'];
    voicemails.sort((a, b) {
      DateTime firstDate = DateFormat("yyyy-MM-dd kk:mm:ss").parse(a['date']);
      DateTime secondDate = DateFormat("yyyy-MM-dd kk:mm:ss").parse(b['date']);
      return firstDate.compareTo(secondDate);
    });
    voicemails = voicemails.reversed.toList();
    voicemailWidgetList = [];
    for (Map voicemail in voicemails) {
      bool putBorder = true;
      voicemail['date'] = DateFormat("yyyy-MM-dd kk:mm:ss")
          .parseUtc(voicemail['date'])
          .toLocal()
          .add(Duration(hours: 2));
      if (voicemail['date'].toString().substring(0, 10) != lastDate) {
        lastDate = voicemail['date'].toString().substring(0, 10);
        voicemailWidgetList.add(Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
                    .format(DateFormat("yyyy-MM-dd").parse(lastDate)),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              )),
        ));
        putBorder = false;
      }
      voicemailWidgetList
          .add(VoicemailIconTile(voicemail: voicemail, putBorder: putBorder));
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("Voice Mails");
    return Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          backgroundColor: AppColors.lightGrey,
          elevation: 0,
          title: Text(
            "Voice Mails",
            style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: numberBoxRow,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // ListTile(title: Text("Hi"))
                Expanded(
                  child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: SizedBox(
                        height: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: voicemailWidgetList,
                          ),
                        ),
                      )),
                )
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
}

class VoicemailIconTile extends StatefulWidget {
  const VoicemailIconTile({
    Key? key,
    required this.voicemail,
    required this.putBorder,
  }) : super(key: key);

  final Map voicemail;
  final bool putBorder;

  @override
  State<VoicemailIconTile> createState() => _VoicemailIconTileState();
}

class _VoicemailIconTileState extends State<VoicemailIconTile>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    bool playing = false;
    return Container(
      decoration: BoxDecoration(
          border: widget.putBorder
              ? Border(
                  top: BorderSide(
                      width: 1, color: AppColors.darkGrey.withOpacity(0.4)))
              : null),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: ListTile(
          title: Text(
            CallProvider.formatNumber(widget.voicemail['caller']),
            style: TextStyle(
                color: AppColors.lightestGrey,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightestGrey,
            ),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.person,
                color: AppColors.blue,
                size: 24,
              ),
            ),
          ),
          trailing: GestureDetector(
              onTap: () {
                // TODO: CHECK VOICEMAIL PLAY
                AudioPlayer _audioPlayer = AudioPlayer();
                if (_animationController.isCompleted) {
                  _audioPlayer.stop();
                  _animationController.reverse();
                  return;
                }
                _animationController.forward();
                _audioPlayer.play(widget.voicemail['file_url']).then((value) {
                  // print("End");
                  // _animationController.reverse();
                });
                StreamSubscription _stremSubcription =
                    _audioPlayer.onPlayerCompletion.listen((event) {
                  _audioPlayer.stop();
                  _animationController.reverse();
                });
              },
              child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _animationController,
                  size: 28,
                  color: AppColors.green)),
          subtitle: Text(
            // "",
            // "Duration: " +
            // (voicemail['duration'] == null
            //     ? "Error"
            //     : (voicemail['duration'].toString() + 's')),
            DateFormat(DateFormat.HOUR_MINUTE).format(DateFormat("kk:mm:ss")
                .parse(widget.voicemail['date'].toString().substring(11))),
            style: TextStyle(color: AppColors.lightestGrey, fontSize: 11),
          ),
        ),
      ),
    );
  }
}
