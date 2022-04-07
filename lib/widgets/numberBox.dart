import 'package:caller_app/models/CompanyModel.dart';
import 'package:caller_app/variables/colors.dart';
import 'package:flutter/material.dart';

import '../providers/callProvider.dart';

// class NumberBoxRowWidget extends StatefulWidget {
//   const NumberBoxRowWidget({Key? key}) : super(key: key);

//   @override
//   State<NumberBoxRowWidget> createState() => _NumberBoxRowWidgetState();
// }

// class _NumberBoxRowWidgetState extends State<NumberBoxRowWidget> {
//   String selected = "Acme Inc.";
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 70,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           NumberBoxWidget(
//             name: "Acme Inc.",
//             number: "+1 (832) 632-8103",
//             selected: selected,
//             onTap: (label) {
//               selected = label;
//               setState(() {});
//             },
//           ),
//           NumberBoxWidget(
//             name: "Second Company",
//             number: "+1 (509) 519-2082",
//             selected: selected,
//             onTap: (label) {
//               selected = label;
//               setState(() {});
//             },
//           ),
//           NumberBoxWidget(
//             name: "Third Company",
//             number: "+1 (720) 730-9599",
//             selected: selected,
//             onTap: (label) {
//               selected = label;
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

class NumberBoxWidget extends StatefulWidget {
  String name = '';
  String number = '';
  String uuid = '';
  CompanyModel selected;
  Function(String) onTap;
  NumberBoxWidget({
    Key? key,
    required this.name,
    required this.number,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NumberBoxWidget> createState() => _NumberBoxWidgetState();
}

class _NumberBoxWidgetState extends State<NumberBoxWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        print("Hi");
        widget.onTap(widget.name);
      },
      child: Container(
        height: 50,
        width: size.width * 0.3,
        // decoration: BoxDecoration(
        //     color: widget.selected.phoneNumbers[0] == widget.number
        //         ? AppColors.blue
        //         : Colors.grey[400]!.withOpacity(0.5),
        //     borderRadius: BorderRadius.circular(15)),
        decoration: BoxDecoration(
            color: AppColors.darkGrey,
            boxShadow: widget.selected.phoneNumbers[0] == widget.number
                ? [
                    BoxShadow(
                      color: AppColors.lightBlue.withOpacity(0.2),
                      blurRadius: 2,
                      spreadRadius: 2,
                    )
                  ]
                : [],
            gradient: widget.selected.phoneNumbers[0] == widget.number
                ? LinearGradient(
                    // radius: 1,
                    // stops: [0.6, 1],
                    colors: [AppColors.blue, AppColors.lightBlue])
                : null,
            borderRadius: BorderRadius.circular(15)),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: FittedBox(
                child: Text(
                  widget.name,
                  style: TextStyle(
                      color: AppColors.white,
                      // fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Text(
              CallProvider.formatNumber(widget.number),
              style: TextStyle(color: AppColors.white, fontSize: 11),
            ),
            SizedBox(height: 5)
          ],
        )),
      ),
    );
  }
}
