import 'package:flutter/material.dart';

abstract final class TrilumaColors {
  static const brand = Color(0xFF083C35);
  static const brandSecondary = Color(0xFF0D4B42);
  static const background = Color(0xFFF8F5EE);
  static const surface = Color(0xFFFFFCF7);
  static const muted = Color(0xFFEFECE4);
  static const text = Color(0xFF102F2A);
  static const secondary = Color(0xFF5B716A);
  static const gold = Color(0xFFBE9146);
  static const paleGold = Color(0xFFEAD7AA);
  static const teal = Color(0xFF55C7BB);
  static const lilac = Color(0xFFA979DA);
  static const border = Color(0xFFE5E0D6);
}

abstract final class TrilumaTheme {
  static const editorial = TextStyle(
    fontFamily: 'DM Serif Display',
    fontWeight: FontWeight.w400,
    color: TrilumaColors.brand,
    height: 1.16,
  );
  static const cardRadius = BorderRadius.all(Radius.circular(16));
  static const heroRadius = BorderRadius.all(Radius.circular(24));
  static final light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: TrilumaColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TrilumaColors.brand,
      primary: TrilumaColors.brand,
      secondary: TrilumaColors.gold,
      surface: TrilumaColors.surface,
      onSurface: TrilumaColors.text,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, height: 1.3),
    ).apply(bodyColor: TrilumaColors.text, displayColor: TrilumaColors.brand),
    iconTheme: const IconThemeData(color: TrilumaColors.brand, size: 22),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: const RoundedRectangleBorder(borderRadius: cardRadius),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
  );
}
