import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class helper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'utodo.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new task
  static Future<int> createTask(String title, String? descrption) async {
    final db = await helper.db();

    final data = {'title': title, 'description': descrption};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all tasks
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await helper.db();
    return db.query('items', orderBy: "id");
  }

  // Read a single task
  static Future<List<Map<String, dynamic>>> getTask(int id) async {
    final db = await helper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update a task by id
  static Future<int> updateTask(
      int id, String title, String? descrption) async {
    final db = await helper.db();

    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete a task
  static Future<void> deleteTask(int id) async {
    final db = await helper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a task: $err");
    }
  }
}
