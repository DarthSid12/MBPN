import 'package:caller_app/variables/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/callProvider.dart';

class SingleContactPage extends StatefulWidget {
  final Map contactDetails;
  const SingleContactPage({Key? key, required this.contactDetails})
      : super(key: key);

  @override
  State<SingleContactPage> createState() => _SingleContactPageState();
}

class _SingleContactPageState extends State<SingleContactPage> {
  String fromAddress = '';
  String toAddress = '';
  String date = '';
  String duration = '';
  @override
  void initState() {
    super.initState();
    print(widget.contactDetails);
    fromAddress = """
${widget.contactDetails['from_city']}
${widget.contactDetails['from_state']}
${widget.contactDetails['from_country']}, ${widget.contactDetails['from_zip']}
""";
    toAddress = """
${widget.contactDetails['to_city']}
${widget.contactDetails['to_state']}
${widget.contactDetails['to_country']}, ${widget.contactDetails['to_zip']}
""";
    date = DateFormat('MMM dd, kk:mm').format(DateFormat('yyyy-MM-dd kk:mm:ss')
        .parse(widget.contactDetails['created_at']));
    duration = widget.contactDetails['duration'].toString();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.darkGrey,
        title: (Text(CallProvider.formatNumber(
            widget.contactDetails['direction'] == 'inbound'
                ? widget.contactDetails['from']
                : widget.contactDetails['to']))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: size.height * 0.05,
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
          //Address
          Text(
            "Address:",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Text(
            widget.contactDetails['direction'] == 'inbound'
                ? fromAddress
                : toAddress,
            style: TextStyle(
              color: AppColors.lightestGrey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          ListTile(
              // tileColor: AppColors.lightestGrey,
              title: Text(
                widget.contactDetails['direction'] == 'inbound'
                    ? "Incoming Call"
                    : "Outgoing call",
                style: TextStyle(
                  color: AppColors.white,
                ),
              ),
              subtitle: Text(
                date,
                style: TextStyle(
                  color: AppColors.white,
                ),
              ),
              leading: Icon(
                widget.contactDetails['direction'] == 'inbound'
                    ? Icons.call_received
                    : Icons.call_made,
                color: AppColors.white,
              ))
        ]),
      ),
    );
  }
}
