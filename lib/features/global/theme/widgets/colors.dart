import 'package:flutter/material.dart';

const kSpacingUnit = 10;
const kPrimaryColor = Color(0xFFA8C4EE);

Color buttoncolor = const Color(0xFF91C964);

const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFE0EAFC),
    Color(0xFFC4D7ED),
  ],
);
const kwhiteGradientColor = LinearGradient(colors: [
  Color.fromARGB(255, 255, 255, 255), // White Cream
  Color.fromARGB(255, 255, 255, 255), // White Cream
]);
// ignore: constant_identifier_names
const KgreyColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromARGB(255, 85, 82, 82),
    Color.fromARGB(255, 122, 118, 118)
  ], // Use the same color twice for a solid effect
);

const kSecondaryColor = Color(0xFF979797);

const kAnimationDuration = Duration(milliseconds: 200);

const headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const subheadingStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Color.fromARGB(255, 47, 20, 94),
  height: 1.5,
);
