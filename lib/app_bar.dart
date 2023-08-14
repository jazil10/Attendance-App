import 'package:flutter/material.dart';
import 'user_profile.dart'; // Import the user profile page

AppBar buildAppBar(GlobalKey<ScaffoldState> scaffoldKey, BuildContext context) {
  return AppBar(
    backgroundColor: Colors.green[900],
    title: Text('Smart HCM App'),
    centerTitle: true,
    leading: IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        scaffoldKey.currentState!.openDrawer();
      },
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.account_circle),
        onPressed: () {
          // Navigate to the user profile page when clicked
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfilePage()),
          );
        },
      ),
    ],
  );
}
