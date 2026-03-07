import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shizuku_service.dart';

// -------------------- Constants (edit these URLs) --------------------
const String BANNER_URL = 'https://raw.githubusercontent.com/yourusername/yourrepo/main/banner.png';
const String PAK_URL = 'https://raw.githubusercontent.com/yourusername/yourrepo/main/smooth.pak';
const String TARGET_PAK_PATH = '/data/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Content/Paks/smooth.pak';

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

  // Load saved toggle state
  Future<void> _loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _iosToggle = prefs.getBool('iosToggle') ?? false;
    });
  }

  // Save toggle state
  Future<void> _saveToggleState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('iosToggle', value);
  }

  // Called when toggle changes
  Future<void> _onToggleChanged(bool value) async {
    setState(() => _iosToggle = value);
    await _saveToggleState(value);

    if (value) {
      await _applySmoothPak();
    } else {
      setState(() => _statusMessage = '');
    }
  }

  // Download and replace pak file via Shizuku
  Future<void> _applySmoothPak() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Downloading...';
    });

    // 1. Download the .pak file
    final File? downloadedFile = await _downloadFile(PAK_URL, 'smooth.pak');
    if (downloadedFile == null) {
      _showError('Download failed');
      return;
    }

    setState(() => _statusMessage = 'Applying via Shizuku...');

    // 2. Replace file using Shizuku
    final bool success = await ShizukuService.replaceFile(downloadedFile, TARGET_PAK_PATH);

    if (success) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Applied successfully!';
      });
    } else {
      _showError('Failed to apply. Check Shizuku.');
    }
  }

  // Helper: download file
  Future<File?> _downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  void _showError(String msg) {
    setState(() {
      _isProcessing = false;
      _statusMessage = msg;
      _iosToggle = false; // turn toggle off
    });
    _saveToggleState(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('GFX Raaz'),
        actions: const [
          // Optional: add an icon if needed
        ],
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Banner from GitHub
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                BANNER_URL,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey[900],
                  child: const Center(
                    child: Text(
                      'Banner Placeholder',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // iOS Toggle Card
            Card(
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'iOS Smooth Toggle',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    if (_isProcessing)
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2.5),
                      )
                    else
                      CupertinoSwitch(
                        value: _iosToggle,
                        onChanged: _onToggleChanged,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2F),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Drawer with About, Contact, Support
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF12121A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A1A2E)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'GFX Raaz',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Version 1.0',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.info, 'About Us', () => Navigator.pop(context)),
          _drawerItem(Icons.contact_mail, 'Contact Me', () => Navigator.pop(context)),
          _drawerItem(Icons.support_agent, 'Support', () => Navigator.pop(context)),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[200]),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      onTap: onTap,
    );
  }
}