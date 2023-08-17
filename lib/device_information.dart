import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'app_bar.dart';
import 'right_drawer.dart';
import 'user_drawer.dart';

class DeviceInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(GlobalKey<ScaffoldState>(), context),
      drawer: buildUserDrawer(context), // Add this line to show the drawer
      endDrawer:
          buildRightDrawer(context), // Replace with your right drawer widget
      body: DeviceInfoContent(),
    );
  }
}

class DeviceInfoContent extends StatefulWidget {
  @override
  _DeviceInfoContentState createState() => _DeviceInfoContentState();
}

class _DeviceInfoContentState extends State<DeviceInfoContent> {
  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iosInfo;
  late WindowsDeviceInfo winInfo;

  @override
  void initState() {
    super.initState();
    initDeviceInfo();
  }

  Future<void> initDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      iosInfo = await deviceInfo.iosInfo;
    } else if (Platform.isWindows) {
      winInfo = await deviceInfo.windowsInfo;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.blue,
              child: Icon(Icons.device_unknown, size: 120, color: Colors.white),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DeviceInfoRow(
                      icon: Icons.device_hub,
                      title: 'Device Name',
                      value:
                          Platform.isAndroid ? androidInfo.model : iosInfo.name,
                    ),
                    DeviceInfoRow(
                      icon: Icons.devices_other,
                      title: 'Device OS',
                      value: Platform.isAndroid
                          ? "Android"
                          : iosInfo.systemVersion,
                    ),
                    DeviceInfoRow(
                      icon: Icons.info,
                      title: 'Device OS Version',
                      value: Platform.isAndroid
                          ? androidInfo.version.release
                          : iosInfo.utsname.version,
                    ),
                    DeviceInfoRow(
                      icon: Icons.device_unknown,
                      title: 'Device ID',
                      value: Platform.isAndroid
                          ? androidInfo.device
                          : iosInfo.systemVersion,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  DeviceInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.black),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
