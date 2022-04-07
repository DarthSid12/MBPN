import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class CallProvider {
  static void callFunction(String companyNumber, String callingNumber) {
    FlutterPhoneDirectCaller.callNumber(companyNumber.replaceAll("[^\\d]", "") +
        ',8,' +
        callingNumber.replaceAll("[^\\d]", ""));
  }

  static String formatNumber(String phoneNumber) {
    return phoneNumber.substring(0, 2) +
        ' (' +
        phoneNumber.substring(2, 5) +
        ') ' +
        phoneNumber.substring(5, 8) +
        '-' +
        phoneNumber.substring(8);
  }
}
