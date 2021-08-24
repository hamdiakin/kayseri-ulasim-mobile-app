import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelperAlarm {
  static final _databaseName = "alarms.db";
  static final _databaseVersion = 1;

  static final table = "alarm_table";

  
  static final columnId = '_id';
  static final busLine = 'busLine';
  static final destination = 'destination';
  static final busStop = 'busStop';
  static final monday = 'monday';
  static final minBefore = 'minBefore';
  static final timePeriod1 = 'timePeriod1';
  static final timePeriod2 = 'timePeriod2';

  DatabaseHelperAlarm._privateConstructor();
  static final DatabaseHelperAlarm instance = DatabaseHelperAlarm._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY ,
            $busLine TEXT NOT NULL,
            $destination TEXT NOT NULL,
            $busStop TEXT NOT NULL,
            $monday TEXT,
            $minBefore TEXT NOT NULL,
            $timePeriod1 TEXT NOT NULL,
            $timePeriod2 TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }


  Future<int> delete1(String busLine) async {
    Database db = await instance.database;
    return await db.rawDelete("DELETE FROM $table WHERE busLine = ?", [busLine]);
  }
    Future<bool> ifContains(String busLine, String destination) async {
    Database db = await instance.database;
    if (Sqflite.firstIntValue(await db
            .rawQuery("SELECT COUNT(*) FROM $table WHERE busLine = ? and destination=? and busStop=? and minBefore=? and timePeriod1=? and timePeriod2=?", [busLine, destination,busStop, minBefore, timePeriod1, timePeriod2])) >=
        1)
      return Future<bool>.value(true);
    else
      return Future<bool>.value(false);
  }
  
}
