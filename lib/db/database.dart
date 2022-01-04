import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import './checklist.dart';

const String tableVersions = 'versions';
const String columnVersionsSection = 'section';
const String columnVersionsVersion = 'version';

// ----------------------------------------------------------------------------

class DB {
  static final _databaseName = 'db/adventure_companion.db';
  static final _databaseVersion = 1;
  BuildContext context;

  // Make this a singleton class - https://stackoverflow.com/questions/12649573/how-do-you-build-a-singleton-in-dart
  // `instance` is deliberately public
  DB._singleton();
  static final DB instance = DB._singleton();

  // context is required for some population functions
  factory DB({@required BuildContext context}) {
    instance.context = context;
    return instance;
  }

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path, version: _databaseVersion,
        onCreate: (Database db, int version) {
      db.execute('''
            CREATE TABLE $tableVersions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              $columnVersionsSection TEXT,
              $columnVersionsVersion INT
            );
        ''');

      DBChecklist.onCreate(db, version, context);
    });
    // onUpgrade: (Database db, int oldVersion, int newVersion) async {
    //   Batch batch = db.batch();

    //   // OPTIMIZE: if more versions in future make a `migrationWalker()` that upgrades to the next whole int
    //   // To handle upgrade from eg. 1 -> 3; The walker will first do 1 -> 2 and then 2 -> 3.
    //   if (oldVersion == 1 && newVersion == 2) _migrate_1to2(batch);

    //   DBChecklist.onUpgrade(batch, oldVersion, newVersion, context);

    //   dynamic result = await batch.commit();
    //   print(result);
    // }, onDowngrade: (Database db, int oldVersion, int newVersion) async {
    //   Batch batch = db.batch();

    //   if (oldVersion == 2 && newVersion == 1) _migrate_2to1(batch);

    //   DBChecklist.onDowngrade(batch, oldVersion, newVersion, context);

    //   dynamic result = await batch.commit();
    //   print(result);
    // });
  }
}

// -- MIGRATIONS --------------------------------------------------------------

// void _migrate_1to2(Batch batch) {
//   batch.execute('DROP TABLE IF EXISTS Versions;');
//   batch.execute('''
//       CREATE TABLE $tableVersions (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         $columnVersionsSection TEXT,
//         $columnVersionsVersion INT
//       );
//   ''');
// }

// void _migrate_2to1(Batch batch) {
//   batch.execute('DROP TABLE IF EXISTS Versions;');
// }
