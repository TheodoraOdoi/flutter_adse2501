// Import the flutter material package
import 'package:flutter/material.dart';


class RoundedButton extends StatelessWidget {
  // Constants
  final String text;
  final Color colour;
  final VoidCallback onPressed;
  final double width;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderWidth;

  // Constructor
  const RoundedButton(
      {super.key,
        required this.text,
        required this.colour,
        required this.onPressed,
        this.width = 250,
        this.fontSize = 18,
        this.fontWeight = FontWeight.bold,
        this.borderWidth = 4,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            // ignore: deprecated_member_use
            overlayColor: MaterialStateProperty.resolveWith<Color?>
              ((Set<MaterialState> states)
                {
                  if (states.contains(MaterialState.pressed)) {
                    return colour.withAlpha(51); // .2 * 255 = 51
                  }
                  return null;
                }),
            child: Container(
              width: width,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.transparent,
                border: Border.all(
                  width: borderWidth,
                  color: colour,
                ),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colour,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  fontFamily: 'gvtime',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
