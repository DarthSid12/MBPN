import 'dart:convert';

import 'package:caller_app/models/UserModel.dart';
import 'package:caller_app/providers/callProvider.dart';
import 'package:flutter/material.dart';

import '/models/CompanyModel.dart';
import '/providers/apiProvider.dart';
import '/variables/colors.dart';
import '/widgets/numberBox.dart';

class NumPadPage extends StatefulWidget {
  UserModel userModel;
  NumPadPage({Key? key, required this.userModel}) : super(key: key);

  @override
  State<NumPadPage> createState() => _NumPadPageState();
}

class _NumPadPageState extends State<NumPadPage> {
  String number = '';
  late CompanyModel selected;
  List<Widget> numberBoxRow = [];
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    buildSelected();
  }

  buildSelected() async {
    Map response =
        jsonDecode(await ApiProvider.whoAmI(widget.userModel.bearerToken));
    print("Build selected");
    print(response);
    widget.userModel.selected_company =
        response['data']['selected_company'].toString();
    buildNumberBoxRow(true);
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
          onTap: (label) {
            if (selected != company) {
              ApiProvider.switchCompany(
                      widget.userModel.bearerToken, company.uuid)
                  .then((value) {
                print(jsonDecode(value));
              });
            }
            selected = company;
            buildNumberBoxRow(false);
            setState(() {});
          },
        ),
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 12, right: 12),
            child: SizedBox(
              height: 70,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: numberBoxRow),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.56,
            color: AppColors.lightGrey,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  trailing: InkWell(
                      onTap: () {
                        number = number.isEmpty
                            ? ''
                            : number.substring(0, number.length - 1);
                        setState(() {});
                      },
                      child: Icon(
                        Icons.backspace_outlined,
                        color: AppColors.lightestGrey,
                      )),
                ),
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                  color: AppColors.lightestGrey,
                ),
                const SizedBox(
                  height: 5,
                  width: 1,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              NumberWidget('1', ''),
                              NumberWidget('2', 'ABC'),
                              NumberWidget('3', 'DEF'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              NumberWidget('4', 'GHI'),
                              NumberWidget('5', 'JKL'),
                              NumberWidget('6', 'MNO'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              NumberWidget('7', 'PQRS'),
                              NumberWidget('8', 'TUV'),
                              NumberWidget('9', 'WXYZ'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  number += '*';
                                  setState(() {});
                                },
                                child: const Text(
                                  '*',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 32),
                                ),
                              ),
                              NumberWidget(
                                '0',
                                '+',
                                onLongPress: () {
                                  number += '+';
                                  setState(() {});
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  number += '#';
                                  setState(() {});
                                },
                                child: const Text(
                                  '#',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                InkWell(
                  onTap: () async {
                    CallProvider.callFunction(selected.phoneNumbers[0], number);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.call_outlined,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget NumberWidget(String num, String text,
      {Function()? onTap, Function()? onLongPress}) {
    return InkWell(
      onTap: onTap ??
          () {
            number += num;
            setState(() {});
          },
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: <Widget>[
            Text(
              num,
              style: TextStyle(color: AppColors.lightBlue, fontSize: 28),
            ),
            const SizedBox(
              height: 1,
            ),
            Text(
              text,
              style: TextStyle(color: AppColors.lightestGrey, fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
