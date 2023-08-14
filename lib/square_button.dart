import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  SquareButton({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap, // Call the provided onTap callback
      style: ElevatedButton.styleFrom(
          primary: Colors.green[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(85, 85),
          maximumSize: Size(90, 90)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
