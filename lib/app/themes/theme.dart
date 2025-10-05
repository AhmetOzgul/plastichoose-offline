import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Application theme: white surface with accent secondary colors.
ThemeData buildAppTheme() {
  const Color secondaryA = Color(0xFF33CCFF); // #33ccff
  const Color secondaryB = Color(0xFF00FFBF); // #00ffbf
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: secondaryA,
    brightness: Brightness.light,
    surface: Colors.white,
    background: Colors.white,
    primary: Colors.black,
    secondary: secondaryA,
    tertiary: secondaryB,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryA,
        foregroundColor: Colors.black,
      ),
    ),
  );
}
