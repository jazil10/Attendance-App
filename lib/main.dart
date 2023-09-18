import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/Loginpage.dart';
import 'screens/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  var status = await Permission.location.request();

  await SharedPreferences.getInstance().then((prefs) {
    String? token = prefs.getString('token');
    runApp(SmartHCMApp(token));
  });
}

class SmartHCMApp extends StatelessWidget {
  final String? token;

  SmartHCMApp(this.token);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IIL HCM App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color.fromARGB(255, 1, 45, 56),
      ),
      debugShowCheckedModeBanner: false,
      home: token != null ? LandingPage() : LoginPage(),
    );
  }
}
