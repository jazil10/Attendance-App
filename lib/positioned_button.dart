import 'package:flutter/material.dart';

class PositionedButton extends StatelessWidget {
  final int position;
  final String buttonText;
  final VoidCallback? onTap;
  final bool isDisabled; // Add this parameter for button disabled state

  PositionedButton({
    required this.position,
    required this.buttonText,
    this.onTap,
    this.isDisabled = false, // Default to not disabled
  });

  @override
  Widget build(BuildContext context) {
    double buttonSize = 70.0;

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.35 -
          (buttonSize * 2) * (position - 1),
      left: position % 2 == 0 ? null : 0,
      right: position % 2 == 0 ? 0 : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap, // Use the provided onTap callback
        child: Text(buttonText), // Use the provided buttonText
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(20),
          shape: CircleBorder(),
          minimumSize: Size(buttonSize, buttonSize),
          elevation: 0,
          backgroundColor: isDisabled ? Colors.grey : null, // Gray background when disabled
        ),
      ),
    );
  }
}
