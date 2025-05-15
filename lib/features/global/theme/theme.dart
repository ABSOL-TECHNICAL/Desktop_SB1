import 'package:flutter/material.dart';

class AppTheme {
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color appBarColor = Colors.white;
  static const Color appBarIconColor = Colors.black;
  static const Color appBarTitleColor = Colors.black;
  static const Color bodyTextColor = Colors.black;
  static const Color displayLargeColor = Colors.orange;
  static const Color displayMediumColor = Colors.black;
  static const Color labelLargeColor = Colors.black;
  static const Color titleMediumColor = Colors.black;
  static const Color dialogBackgroundColor = Colors.blueAccent;
  static const Color inputEnabledBorderColor =
      Color.fromARGB(255, 121, 120, 120);
  static const Color inputFocusedBorderColor = Colors.orange;
  static const Color inputBorderColor = Colors.grey;
  static const Color inputLabelStyleColor = Colors.black;
  static const Color inputHintStyleColor = Colors.black;
  static const Color elevatedButtonBackgroundColor = Colors.orange;
  static const Color elevatedButtonForegroundColor = Colors.white;

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: "Roboto",
      appBarTheme: const AppBarTheme(
        color: appBarColor,
        elevation: 0,
        iconTheme: IconThemeData(color: appBarIconColor),
        titleTextStyle: TextStyle(color: appBarTitleColor),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: bodyTextColor,
        ),
        headlineMedium: TextStyle(fontSize: 14, color: Colors.black),
        headlineLarge: TextStyle(
          fontSize: 18,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        bodyMedium: TextStyle(color: bodyTextColor),
        bodySmall: TextStyle(
          color: Color.fromARGB(255, 253, 250, 250),
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        displayLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: displayLargeColor,
        ),
        labelSmall: TextStyle(
          color: bodyTextColor,
          fontFamily: 'Roboto',
          fontSize: 12,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: scaffoldBackgroundColor,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          //fontWeight: FontWeight.bold,
          color: labelLargeColor,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: titleMediumColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 2, 2, 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 23, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputEnabledBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputFocusedBorderColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        labelStyle: const TextStyle(
          color: inputLabelStyleColor,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
        hintStyle: const TextStyle(color: inputHintStyleColor),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: elevatedButtonBackgroundColor,
          foregroundColor: elevatedButtonForegroundColor,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      fontFamily: "Roboto",
      appBarTheme: const AppBarTheme(
        color: appBarColor,
        elevation: 0,
        iconTheme: IconThemeData(color: appBarIconColor),
        titleTextStyle: TextStyle(color: appBarTitleColor),
      ),
      textTheme: TextTheme(
        bodyLarge: const TextStyle(
          color: Colors.white,
        ),
        headlineLarge: const TextStyle(
          fontSize: 18,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        bodyMedium: const TextStyle(color: Colors.white60),
        bodySmall: const TextStyle(
          color: Color.fromARGB(255, 253, 250, 250),
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        displayLarge: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: displayLargeColor,
        ),
        labelSmall: TextStyle(
          color: Colors.grey[350],
          fontFamily: 'Roboto',
          fontSize: 12,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: bodyTextColor,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          //fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: const TextStyle(fontSize: 14, color: Colors.black),
        titleMedium: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: appBarColor,
        ),
        titleSmall: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 23, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputEnabledBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputFocusedBorderColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        labelStyle: const TextStyle(
          color: inputLabelStyleColor,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
        hintStyle: const TextStyle(color: inputHintStyleColor),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: elevatedButtonBackgroundColor,
          foregroundColor: elevatedButtonForegroundColor,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
    );
  }
}
