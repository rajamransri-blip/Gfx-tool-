import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toggle Tool',

      theme: ThemeData(
        cardTheme: const CardThemeData(
          elevation: 3,
        ),
      ),

      home: HomePage(),
    );
  }
}