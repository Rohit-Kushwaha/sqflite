import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Sqlite {
  // Database is from sqflite package
  // First Step creating table
  static Future<void> createTables(Database database) async {
    await database.execute("""CREATE TABLE items(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
    title TEXT,
    description TEXT,
    )
    """);
  }

//Second step
  static Future<Database> db() async {
    return openDatabase("test.path", version: 1,
        onCreate: (Database database, int version) async {
      //opening database and adding table if not present
      await createTables(database);
    });
  }

  static Future<int> createItems(String title, String description) async {
    // wait for checking if the table is created or not and created object at same time
    final db = await Sqlite.db();
    // whatever you want to store in database map it
    final data = {'title': title, "description": description};
    // insert items according to id
    final id = await db.insert('items', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

// this method is responsible for getting all items in the list or database
  static Future<List<Map<String, dynamic>>> getAllItemsData() async {
    // checking if it's present database connection
    final db = await Sqlite.db();
    // return data if present in database
    return db.query('items', orderBy: "id");
  }

// this method is responsible for getting single item in the list or database
  static Future<List<Map<String, dynamic>>> getSingleItemData(int id) async {
    // checking if it's present database connection
    final db = await Sqlite.db();
    // return data if present in database
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // method responsible for updating certain row
  static Future<int> updateItem(
      int id, String title, String description) async {
    final db = await Sqlite.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };

    final result =
        await db.update('items', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItems(int id) async {
    final db = await Sqlite.db();
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint("Something went wrong");
    }
  }
}
