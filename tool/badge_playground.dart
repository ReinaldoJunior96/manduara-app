import 'package:flutter/material.dart';
import 'package:triluma/screens/badge_playground_page.dart';
import 'package:triluma/theme/triluma_theme.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Triluma · Badge Playground',
      debugShowCheckedModeBanner: false,
      theme: TrilumaTheme.light,
      home: const BadgePlaygroundPage(),
    ),
  );
}
