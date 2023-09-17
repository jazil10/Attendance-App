import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this line
import 'screens/Loginpage.dart';
import 'screens/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that widgets are initialized

  // Request location permission
  var status = await Permission.location.request();

  runApp(SmartHCMApp());
}

class SmartHCMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IIL HCM App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color.fromARGB(255, 1, 45, 56),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
