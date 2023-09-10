import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CheckInPopup {
  static Future<void> showPopup(
      BuildContext context, double distanceInMeters) async {
    if (distanceInMeters <= 100) {
      Fluttertoast.showToast(
        msg: "Check in possible",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Not in location",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}

class CheckOutPopup {
  static Future<void> showPopup(
      BuildContext context, double distanceInMeters) async {
    if (distanceInMeters <= 100) {
      Fluttertoast.showToast(
        msg: "Check Out possible",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Not in location",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
