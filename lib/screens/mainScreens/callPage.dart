import 'dart:convert';

import 'package:caller_app/models/CompanyModel.dart';
import 'package:caller_app/models/UserModel.dart';
import 'package:caller_app/providers/apiProvider.dart';
import 'package:caller_app/providers/authProvider.dart';
import 'package:caller_app/providers/callProvider.dart';
import 'package:caller_app/screens/singleContact.dart';
import 'package:caller_app/variables/colors.dart';
import 'package:caller_app/widgets/contactIconTile.dart';
import 'package:caller_app/widgets/numberBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class CallPage extends StatefulWidget {
  UserModel userModel;
  CallPage({Key? key, required this.userModel}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late CompanyModel selected;
  Widget callsListWidget = Column(
    children: <Widget>[],
  );
  List<Widget> numberBoxRow = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    callsListWidget = Column();
    // print("Hi");
    // ApiProvider.getCompany(widget.userModel.bearerToken, selected.uuid)
    //     .then((value) {
    //   // print(value);
    // });
    buildSelected();
  }

  buildSelected() async {
    loading = true;
    setState(() {});
    await FlutterLibphonenumber().init();
    Map response =
        jsonDecode(await ApiProvider.whoAmI(widget.userModel.bearerToken));
    // print(response);
    widget.userModel.selected_company =
        response['data']['selected_company'].toString();
    buildNumberBoxRow(true);
    if(mounted){
      setState(() {});
    }
    await buildCalls();
    loading = false;
    if(mounted){
    setState(() {});
    }
  }

  void buildNumberBoxRow(bool buildSelected) {
    numberBoxRow = [];
    try {
      if (buildSelected) {
        selected = widget.userModel.companies
            .where(
                (element) => element.uuid == widget.userModel.selected_company)
            .first;
      }
    } catch (e) {
      selected =
          CompanyModel(uuid: "", name: "", phoneNumbers: [], timezone: "");
    }

    for (CompanyModel company in widget.userModel.companies) {
      // print(company.name);

      numberBoxRow.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal:5.0),
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
              loading = true;
    if(mounted){

              setState(() {});
              await buildCalls();
              loading = false;
              setState(() {});
    }
            }
            // callsListWidget = Column(children: [
            //   ContactIconTile(number: '+1 (832) 806-4731', time: '(11:24 am)')
            // ]);
            loading = false;
            setState(() {});
          },
        ),
      ));

    }

    // print(selected);
    if(mounted){

    setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(selected);
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
          backgroundColor: AppColors.lightGrey,
          elevation: 0,
          title: Text(
            "Calls",
            style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                DateTimeRange? dateTimeRange = await showDateRangePicker(
                    context: context,
                    builder: (ctx,child){
                      return Theme(
                        data: ThemeData(
                          backgroundColor: AppColors.lightestGrey,
                          // scaffoldBackgroundColor: AppColors.lightestGrey,
                          // dialogBackgroundColor: AppColors.lightestGrey,
                          primaryColor: AppColors.darkGrey,
          accentColor:AppColors.darkGrey,
          colorScheme: ColorScheme.light(primary: AppColors.darkGrey),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary
          ),
                        ),
                        child: child??Container(),
                      )
                    },
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    initialDateRange: DateTimeRange(
                        start: DateTime.now().subtract(Duration(days: 14)),
                        end: DateTime.now()));
                if (dateTimeRange != null) {
                  print(dateTimeRange);
                  callsListWidget = Column();
                  loading = true;
                  setState(() {
                    
                  });
                  await buildCalls(dateTimeRange: dateTimeRange);
                     loading = false;
                  if(mounted){setState(() {
                    
                  });}
                }
              },
              child: Icon(
                Icons.calendar_month,
                color: AppColors.lightBlue,
              ),
            ),
            SizedBox(
              width: 20,
            )
          ]),
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
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    print("Transition");
                    return AnimatedSwitcher.defaultTransitionBuilder(
                        child, animation);
                  },
                  child: callsListWidget,
                ),
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
      ),
    );
  }

  Widget ContactIconTile(Map calls, bool putBorder) {
    return Container(
      decoration: BoxDecoration(
          border: putBorder
              ? Border(
                  top: BorderSide(
                      width: 1, color: AppColors.darkGrey.withOpacity(0.4)))
              : null),
      child: ListTile(
        onTap: (){
          Navigator.push(context, PageTransition(child:SingleContactPage(contactDetails: calls), ctx: context,duration: Duration(milliseconds: 500),type: PageTransitionType.fade));
        },
          title: Text(
            CallProvider.formatNumber(calls['from']?? calls['caller']),
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
                CallProvider.callFunction(
                    selected.phoneNumbers[0], calls['caller']);
              },
              child: Icon(Icons.phone, color: AppColors.green)),
          subtitle: Text(
            DateFormat(DateFormat.HOUR_MINUTE).format(DateFormat("kk:mm:ss")
                .parse(calls['created_at'].toString().substring(11))),
            style: TextStyle(color: AppColors.lightestGrey, fontSize: 11),
          )),
    );
  }

  buildCalls({DateTimeRange? dateTimeRange}) async {
    String lastDate = '';
    Map response =
        jsonDecode(await ApiProvider.getCalls(widget.userModel.bearerToken,dateTimeRange:dateTimeRange));
    // print(response);
    if (response['status'] == 0) {
      print("Error 1");
      // print(response["errors"].toString());
      if (response["errors"] != null) {
        print("Error 2");
        AuthProvider.logOut(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.blue,
            content: Text(
              "Session timed out",
              style: TextStyle(color: AppColors.white, fontSize: 16),
            )));
        return;
      }
    }
    List calls = response['data'];
    calls.sort((a, b) {
      DateTime firstDate =
          DateFormat("yyyy-MM-dd kk:mm:ss").parse(a['created_at']);
      DateTime secondDate =
          DateFormat("yyyy-MM-dd kk:mm:ss").parse(b['created_at']);
      return firstDate.compareTo(secondDate);
    });
    calls =calls.reversed.toList();
    List<Widget> callWidgetList = [];
    // lastDate = calls[0]['created_at'].toString().substring(0, 10);
    // callWidgetList.add(Padding(
    //   padding: const EdgeInsets.only(left: 12.0),
    //   child: Align(
    //       alignment: Alignment.centerLeft,
    //       child: Text(
    //         lastDate,
    //         style: TextStyle(
    //           color: AppColors.white,
    //           fontSize: 18,
    //         ),
    //       )),
    // ));
    DateFormat messageDateFormat = DateFormat(
      "yyyy-MM-dd kk:mm:ss",
    );
    for (Map call in calls) {
      
    call['created_at'] = messageDateFormat.format(messageDateFormat
        .parseUTC(call['created_at'].toString().substring(0, 19))
        .toLocal()
        .add(Duration(hours: 2)),
        );  
      bool putBorder = true;
      if (call['created_at'].toString().substring(0, 10) != lastDate) {
        lastDate = call['created_at'].toString().substring(0, 10);
        callWidgetList.add(Padding(
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
      callWidgetList.add(ContactIconTile(call, putBorder));
    }
    callsListWidget = SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: callWidgetList,
        ),
      ),
    );
    if(mounted){
    setState(() {});}
  }
}
