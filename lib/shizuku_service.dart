import 'dart:io';
import 'package:shizuku_api/shizuku_api.dart';

class ShizukuService {

  static Future<bool> replaceFile(File sourceFile, String targetPath) async {

    try {

      // Check if Shizuku service is running
      if (!await ShizukuApi.isRunning()) {
        return false;
      }

      // Request permission if needed
      final granted = await ShizukuApi.requestPermission();
      if (!granted) {
        return false;
      }

      // Shell command to replace file
      final command =
          'cat "${sourceFile.path}" > "$targetPath" && chmod 644 "$targetPath"';

      final process = await ShizukuApi.run(command);

      if (process.exitCode == 0) {
        return true;
      }

      return false;

    } catch (e) {
      return false;
    }
  }
}