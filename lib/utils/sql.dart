import 'package:sqflite/sqflite.dart' as sql;
import 'package:flutter/foundation.dart';

class SQL {
  static Future<void> create_tables(sql.Database database) async {
    await database.execute("""CREATE TABLE logs(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      message TEXT,
      sentByUser INTEGER(2)
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("fluently.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await create_tables(database);
    });
  }

  static Future<int> insert_item(String message, int sentByUser) async {
    final db = await SQL.db();
    final data = {'message': message, 'sentByUser': sentByUser};
    final id = await db.insert('logs', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> get_items() async {
    final db = await SQL.db();
    return db.query('logs', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> get_item(int id) async {
    final db = await SQL.db();
    return db.query('logs', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<void> delete_item(int id) async {
    final db = await SQL.db();
    try {
      await db.delete("logs", where: "id=?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong while deleting an item: $err");
    }
  }

  static Future<bool> delete_all() async {
    final db = await SQL.db();
    try {
      await db.rawQuery("DELETE FROM logs");
      return true;
    } catch (err) {
      return false;
    }
  }
}
