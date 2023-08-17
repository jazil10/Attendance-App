import 'package:flutter/material.dart';
import 'user_profile.dart'; // Import the user profile page
import 'device_information.dart'; // Import the device information page

Drawer buildRightDrawer(BuildContext context) {
  // Replace this with the user's profile photo or initials
  Widget userAvatar = CircleAvatar(
    backgroundColor: Colors.blue, // You can customize the color
    child: Icon(Icons.person, color: Colors.white),
    radius: 40,
  );

  return Drawer(
    child: Column(
      children: [
        Container(
          width: 320,
          height: 120,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 36, 35, 35),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  FractionalTranslation(
                    translation: Offset(0, 0.5),
                    child: Container(
                      color: Color.fromARGB(255, 49, 48, 48),
                      height: 70,
                      width: double.infinity,
                    ),
                  ),
                  FractionalTranslation(
                    translation: Offset(0, -0.5),
                    child: Container(
                      color: Colors.white,
                      height: 70,
                      width: double.infinity,
                    ),
                  ),
                  userAvatar, // Display user's profile photo or initials
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 1,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 115, vertical: 5),
          color: Color.fromARGB(255, 36, 35, 35),
          child: Text(
            'MANAGER',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('Profile'),
          leading: Icon(Icons.person),
          onTap: () {
            // Navigate to the user profile page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfilePage()),
            );
          },
        ),
        ListTile(
          title: Text('Device Information'),
          leading: Icon(Icons.device_hub),
          onTap: () {
            // Navigate to the device information page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeviceInfoPage()),
            );
          },
        ),
        ListTile(
          title: Text('Settings'),
          leading: Icon(Icons.settings),
          onTap: () {
            // Handle settings option
          },
        ),
        ListTile(
          title: Text('Logout'),
          leading: Icon(Icons.exit_to_app),
          onTap: () {
            // Handle logout option
          },
        ),
      ],
    ),
  );
}
