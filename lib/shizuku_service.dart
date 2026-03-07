import 'dart:io';
import 'package:shizuku/shizuku.dart';

class ShizukuService {
  /// Check and request Shizuku permission, then replace the file.
  static Future<bool> replaceFile(File sourceFile, String targetPath) async {
    if (!await Shizuku.isAvailable()) return false;

    // Check permission
    if (await Shizuku.checkSelfPermission() != Permission.granted) {
      final granted = await Shizuku.requestPermission();
      if (!granted) return false;
    }

    // Shell command: copy file and set permissions
    final cmd = 'cat "${sourceFile.path}" > "$targetPath" && chmod 644 "$targetPath"';
    try {
      final result = await Shizuku.executeShellCommand(['sh', '-c', cmd]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}