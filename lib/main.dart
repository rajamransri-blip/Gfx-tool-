import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final ThemeData baseTheme = ThemeData.dark();

    return MaterialApp(
      title: 'GFX Raaz',
      debugShowCheckedModeBanner: false,

      theme: baseTheme.copyWith(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFF0A0A0F),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),

        cardTheme: const CardTheme(
          color: Color(0xFF1E1E2F),
          elevation: 4,
          margin: EdgeInsets.all(12),
        ),
      ),

      home: const HomePage(),
    );
  }
}