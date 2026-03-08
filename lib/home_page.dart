import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool toggle = false;

  @override
  void initState() {
    super.initState();
    loadState();
  }

  loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      toggle = prefs.getBool("toggle") ?? false;
    });
  }

  saveState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("toggle", value);
  }

  onToggle(bool value) async {

    setState(() {
      toggle = value;
    });

    saveState(value);

    if (value) {
      await FileService.copyFile();
    } else {
      await FileService.deleteFile();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Toggle File Tool"),
        centerTitle: true,
      ),

      body: Center(
        child: CupertinoSwitch(
          value: toggle,
          onChanged: onToggle,
        ),
      ),
    );
  }
}