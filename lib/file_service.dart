import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {

  static Future<File> _getFile() async {

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/demo_file.txt");

    return file;
  }

  static Future<void> copyFile() async {

    final file = await _getFile();

    if (!file.existsSync()) {
      await file.writeAsString("Hello Flutter File");
    }
  }

  static Future<void> deleteFile() async {

    final file = await _getFile();

    if (file.existsSync()) {
      await file.delete();
    }
  }
}