import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import './checklist.dart';

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

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database db, int version) {
        return DBChecklist.onCreate(db, version, context);
      },
    );
  }
}
