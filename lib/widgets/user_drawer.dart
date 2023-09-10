import 'package:flutter/material.dart';
import '../screens/landing_page.dart';

Drawer buildUserDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        Container(
          // Equal width box for "Smart HCM APP" and icon
          width: 320,
          height: 120, // Adjust the height as needed
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 87, 82, 82), // Light grey background color
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with your logo
              Icon(
                Icons.how_to_reg,
                size: 80,
                color: Color.fromARGB(255, 245, 243, 243), // Icon color
              ),
              SizedBox(height: 10),
              Text(
                "IIL HCM APP",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          // Box for "Menu" text
          padding: EdgeInsets.symmetric(horizontal: 126, vertical: 5),
          color: Color.fromARGB(255, 151, 140, 140), // Dark grey box color
          child: Text(
            'MENU',
            style: TextStyle(
              color: const Color.fromARGB(255, 61, 61, 61), // Text color
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('Home'),
          leading: Icon(Icons.home),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            // Navigate to the landing page
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => LandingPage()),
            // );
          },
        ),
        ListTile(
          title: Text('Tracking'),
          leading: Icon(Icons.location_pin),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            // Handle device information option
          },
        ),
        ListTile(
          title: Text('About'),
          leading: Icon(Icons.edit_document),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            // Handle settings option
          },
        ),
        ListTile(
          title: Text('Videos'),
          leading: Icon(Icons.videocam),
          onTap: () {
            // Close the drawer
            Navigator.pop(context);
            // Handle logout option
          },
        ),
      ],
    ),
  );
}
