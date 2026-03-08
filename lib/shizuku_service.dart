import 'dart:io';
import 'package:shizuku_api/shizuku_api.dart';

class ShizukuService {

  /// Check and request Shizuku permission, then replace the file
  static Future<bool> replaceFile(File sourceFile, String targetPath) async {

    try {

      // Check Shizuku service
      final available = await ShizukuApi.pingBinder();
      if (!available) {
        return false;
      }

      // Permission check
      final permission = await ShizukuApi.checkSelfPermission();

      if (!permission) {
        final granted = await ShizukuApi.requestPermission();
        if (!granted) return false;
      }

      // Shell command
      final cmd =
          'cat "${sourceFile.path}" > "$targetPath" && chmod 644 "$targetPath"';

      final result = await ShizukuApi.exec(cmd);

      if (result == null) {
        return false;
      }

      return true;

    } catch (e) {
      return false;
    }
  }
}