import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool toggle = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Toggle Tool"),
        centerTitle: true,
      ),

      body: Center(
        child: CupertinoSwitch(
          value: toggle,
          onChanged: (value) {
            setState(() {
              toggle = value;
            });
          },
        ),
      ),
    );
  }
}