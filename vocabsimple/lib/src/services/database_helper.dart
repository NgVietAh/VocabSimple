import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  /// Copy database từ assets vào app directory
  static Future<Database> openDatabaseFromAssets() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocab.db');

    // Kiểm tra xem database đã tồn tại chưa
    final exists = await databaseExists(path);

    if (!exists) {
      
      // Tạo thư mục nếu chưa có
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy database từ assets vào app directory
      ByteData data = await rootBundle.load('assets/database/vocab.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
      
    } else {
    }

    return await openDatabase(path);
  }
}


