import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shizuku_service.dart';

const String BANNER_URL =
    'https://raw.githubusercontent.com/yourusername/yourrepo/main/banner.png';

const String PAK_URL =
    'https://raw.githubusercontent.com/yourusername/yourrepo/main/smooth.pak';

const String TARGET_PAK_PATH =
    '/data/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Content/Paks/smooth.pak';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _iosToggle = false;
  bool _isProcessing = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadToggleState();
  }

  Future<void> _loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _iosToggle = prefs.getBool('iosToggle') ?? false;
    });
  }

  Future<void> _saveToggleState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('iosToggle', value);
  }

  Future<void> _onToggleChanged(bool value) async {

    if (_isProcessing) return;

    setState(() {
      _iosToggle = value;
    });

    await _saveToggleState(value);

    if (value) {
      await _applySmoothPak();
    } else {
      setState(() {
        _statusMessage = '';
      });
    }
  }

  Future<void> _applySmoothPak() async {

    setState(() {
      _isProcessing = true;
      _statusMessage = "Downloading file...";
    });

    final File? downloaded = await _downloadFile(PAK_URL, "smooth.pak");

    if (downloaded == null) {
      _showError("Download failed");
      return;
    }

    setState(() {
      _statusMessage = "Applying with Shizuku...";
    });

    final bool success =
        await ShizukuService.replaceFile(downloaded, TARGET_PAK_PATH);

    if (!mounted) return;

    if (success) {
      setState(() {
        _statusMessage = "Applied successfully";
        _isProcessing = false;
      });
    } else {
      _showError("Failed to apply file");
    }
  }

  Future<File?> _downloadFile(String url, String fileName) async {

    try {

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) return null;

      final dir = await getApplicationDocumentsDirectory();

      final file = File("${dir.path}/$fileName");

      await file.writeAsBytes(response.bodyBytes);

      return file;

    } catch (e) {
      return null;
    }
  }

  void _showError(String msg) {

    setState(() {
      _isProcessing = false;
      _iosToggle = false;
      _statusMessage = msg;
    });

    _saveToggleState(false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF0A0A0F),

      appBar: AppBar(
        title: const Text("GFX Raaz"),
      ),

      drawer: _buildDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                BANNER_URL,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) {
                  return Container(
                    height: 180,
                    color: Colors.black26,
                    child: const Center(
                      child: Text(
                        "Banner",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "iOS Smooth Toggle",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),

                    if (_isProcessing)
                      const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else
                      CupertinoSwitch(
                        value: _iosToggle,
                        onChanged: _onToggleChanged,
                      )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2F),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {

    return Drawer(
      backgroundColor: const Color(0xFF12121A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF1A1A2E),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GFX Raaz",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Version 1.0",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14),
                )
              ],
            ),
          ),

          _drawerItem(Icons.info, "About Us"),
          _drawerItem(Icons.contact_mail, "Contact Me"),
          _drawerItem(Icons.support_agent, "Support"),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title) {

    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[200]),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white70,
            fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}