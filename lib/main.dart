import 'package:flutter/material.dart';
import 'screens/Loginpage.dart';
import 'screens/landing_page.dart';

void main() {
  runApp(SmartHCMApp());
}

class SmartHCMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIL HCM App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color.fromARGB(255, 1, 45, 56),
      ),
      // home: LandingPage(),
       home: LoginPage(),

      debugShowCheckedModeBanner: false,
    );
  }
}
