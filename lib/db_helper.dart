import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? dbLagu;

  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'lagu.db');
    dbLagu = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE lagu(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          duration INTEGER,
          genre TEXT,
          record_type TEXT,
          band TEXT,
          album TEXT,
          release_date TEXT
        )
        ''');
      },
    );
    return dbLagu!;
  }

  static Future<int> insertLagu(Map<String, dynamic> lagu) async {
    final db = dbLagu ?? await initDb();
    return await db.insert('lagu', lagu);
  }

  static Future<List<Map<String, dynamic>>> getAllLagu() async {
    final db = dbLagu ?? await initDb();
    return await db.query('lagu');
  }

  static Future<void> deleteLagu(int id) async {
    final db = dbLagu ?? await initDb();
    await db.delete('lagu', where: "id = ?", whereArgs: [id]);
  }
}
