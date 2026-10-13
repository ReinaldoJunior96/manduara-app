import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/badge_playground_page.dart';
import 'theme/triluma_theme.dart';

export 'screens/home_page.dart' show MyHomePage;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manduarã',
      debugShowCheckedModeBanner: false,
      theme: TrilumaTheme.light,
      home: const TrilumaHomePage(),
      routes: {
        BadgePlaygroundPage.routeName: (_) => const BadgePlaygroundPage(),
      },
    );
  }
}
