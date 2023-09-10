import 'package:flutter/material.dart';
import '../widgets/right_drawer.dart';
import '../widgets/user_drawer.dart';
import 'app_bar.dart';

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Use the same scaffold key here
      appBar: buildAppBar(_scaffoldKey, context),
      drawer: buildUserDrawer(context), // Add this line to show the drawer
      endDrawer:
          buildRightDrawer(context), // Replace with your right drawer widget
      body: UserProfileContent(),
    );
  }
}

class UserProfileContent extends StatelessWidget {
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
              backgroundColor: Colors.blue, // Example background color
              child: Icon(Icons.person, size: 120, color: Colors.white),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Add horizontal padding
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Background color for rows
                  borderRadius: BorderRadius.circular(10), // Add border radius
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileRow(
                        icon: Icons.person,
                        title: 'Username',
                        value: 'JohnDoe'),
                    ProfileRow(
                        icon: Icons.work,
                        title: 'Title',
                        value: 'Software Engineer'),
                    ProfileRow(
                        icon: Icons.account_box,
                        title: 'User ID',
                        value: '12345'),
                    EditableProfileRow(
                      icon: Icons.vpn_key,
                      title: 'Key',
                      value: 'YourKeyHere',
                      onEdit: () {
                        // Implement edit functionality for Key
                      },
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

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  ProfileRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 10, horizontal: 16), // Add horizontal padding
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.black),
          SizedBox(width: 10),
          Text(title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(width: 10),
          Expanded(
            child:
                Text(value, style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class EditableProfileRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onEdit;

  EditableProfileRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onEdit,
  });

  @override
  _EditableProfileRowState createState() => _EditableProfileRowState();
}

class _EditableProfileRowState extends State<EditableProfileRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 10, horizontal: 16), // Add horizontal padding
      child: Row(
        children: [
          Icon(widget.icon, size: 30, color: Colors.black),
          SizedBox(width: 10),
          Text(widget.title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(width: 10),
          Expanded(
            child: Text(widget.value,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: widget.onEdit,
          ),
        ],
      ),
    );
  }
}
