import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

void initializeDatabase() {
  databaseFactory = databaseFactoryFfiWeb; // Set databaseFactory for Web
}
