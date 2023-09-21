import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

Map<int, String> contacts = {
  1: ''' CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          path TEXT
          );'''
};

class SQLiteDataBase {
  static Database? db;

  Future<Database> getDataBase() async {
    if (db == null) {
      return await startDatabase();
    } else {
      return db!;
    }
  }

  Future<Database> startDatabase() async {
    var db =
        await openDatabase(path.join(await getDatabasesPath(), 'database.db'), version: contacts.length, onCreate: (Database db, int version) async {
      for (var i = 1; i <= contacts.length; i++) {
        await db.execute(contacts[i]!);
        debugPrint(contacts[i]!);
      }
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      for (var i = oldVersion + 1; i <= contacts.length; i++) {
        await db.execute(contacts[i]!);
        debugPrint(contacts[i]!);
      }
    });
    return db;
  }
}
