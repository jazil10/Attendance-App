import 'package:flutter/material.dart';

Container buildFooter() {
  return Container(
    color: Colors.black,
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            'Follow us',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: 20), // Add spacing between "Follow us" and icons
        Spacer(), // Align icons to the right
        Icon(
          Icons.facebook,
          color: Colors.white,
          size: 30,
        ),
        SizedBox(width: 10),
        Icon(
          Icons.nature_outlined,
          color: Colors.white,
          size: 30,
        ),
        SizedBox(width: 10),
        Icon(
          Icons.link,
          color: Colors.white,
          size: 30,
        ),
        SizedBox(width: 10),
        Icon(
          Icons.youtube_searched_for,
          color: Colors.white,
          size: 30,
        ),
        // Add more icons as needed
      ],
    ),
  );
}
