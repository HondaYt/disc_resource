import 'package:flutter/material.dart';

final sampleTheme = ThemeData(
  colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.grey[900]!,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: const Color(0xFF0C0C0C),
      onSurface: Colors.white),
);
