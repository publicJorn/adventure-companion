import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import './database.dart';

const String tableChecklistSections = 'checklist_sections';
const String columnSectionGuid = 'guid';
const String columnSectionPosition = 'position';
const String columnSectionName = 'name';
const String columnSectionInfo = 'info';

const String tableChecklistItems = 'checklist_items';
const String columnItemGuid = 'guid';
const String columnItemSectionGuid = 'sectionGuid';
const String columnItemPosition = 'position';
const String columnItemName = 'name';
const String columnItemInfo = 'info';
const String columnItemChecked = 'checked';

// -- MODELS ------------------------------------------------------------------

class ChecklistSection {
  String guid;
  int position;
  String name;
  String info;
  int itemsTotal;
  int itemsChecked;

  ChecklistSection();

  ChecklistSection.fromDBMap(Map<String, dynamic> map) {
    guid = map['guid'];
    position = map['position'];
    name = map['name'];
    info = map['info'];
    itemsTotal = map['itemsTotal'] ?? 0;
    itemsChecked = map['itemsChecked'] ?? 0;
  }

  Map<String, dynamic> toDBMap() {
    return {
      columnSectionGuid: guid,
      columnSectionPosition: position,
      columnSectionName: name,
      columnSectionInfo: info,
    };
  }
}

class ChecklistItem {
  String guid;
  String sectionGuid;
  int position;
  String name;
  String info;
  bool isChecked;

  ChecklistItem();

  ChecklistItem.fromDBMap(Map<String, dynamic> map) {
    guid = map['guid'];
    sectionGuid = map['sectionGuid'];
    position = map['position'];
    name = map['name'];
    info = map['info'];
    isChecked = map['checked'] != null ? map['checked'] > 0 : false;
  }

  Map<String, dynamic> toDBMap() {
    return {
      columnItemGuid: guid,
      columnItemSectionGuid: sectionGuid,
      columnItemPosition: position,
      columnItemName: name,
      columnItemInfo: info,
      columnItemChecked: isChecked ? 1 : 0,
    };
  }
}

// -- GENERIC FUNCTIONS -------------------------------------------------------

Future<Map<String, dynamic>> _fetchJSON(context) async {
  // Fetch content from JSON
  // OPTIMIZE: combine with json_serializable
  String data = await DefaultAssetBundle.of(context).loadString('content/checklist.json');
  return json.decode(data);
}

// -- DB HELPERS --------------------------------------------------------------

class DBChecklist {
  Database db;

  DBChecklist._singleton();
  static final DBChecklist _instance = DBChecklist._singleton();

  factory DBChecklist() {
    return _instance;
  }

  static Future onCreate(Database db, int version, BuildContext context) async {
    Map<String, dynamic> json = await _fetchJSON(context);
    List<dynamic> checklist = json['data']['sections'];

    // Create database entries
    await db.execute('''
        CREATE TABLE $tableChecklistSections (
          $columnSectionGuid TEXT PRIMARY KEY,
          $columnSectionPosition INTEGER NOT NULL,
          $columnSectionName TEXT,
          $columnSectionInfo TEXT
        );
      ''');

    await db.execute('''
        CREATE TABLE $tableChecklistItems (
          $columnItemGuid TEXT PRIMARY KEY,
          $columnItemPosition INTEGER NOT NULL,
          $columnItemSectionGuid TEXT NOT NULL,
          $columnItemName TEXT,
          $columnItemInfo TEXT,
          $columnItemChecked INTEGER NOT NULL DEFAULT 0
        );
      ''');

    db.insert(
      tableVersions,
      {columnVersionsSection: 'checklist', columnVersionsVersion: json['version']},
    );

    Batch batch = db.batch();
    int sectionIter = 0;
    int itemIter;

    checklist.forEach((section) {
      // Build proper section instance so we're sure it's parsed correctly
      section.addAll({
        'position': sectionIter++,
      });
      ChecklistSection sectionInstance = ChecklistSection.fromDBMap(section);

      batch.insert(
        tableChecklistSections,
        sectionInstance.toDBMap(),
      );

      itemIter = 0;

      section['items'].forEach((item) {
        // Build proper item instance
        item.addAll({
          'sectionGuid': sectionInstance.guid,
          'position': itemIter++,
        });
        ChecklistItem itemInstance = ChecklistItem.fromDBMap(item);

        batch.insert(
          tableChecklistItems,
          itemInstance.toDBMap(),
        );
      });
    });

    // Uninteresting results at this stage and `noResult` makes it faster
    await batch.commit(noResult: true);
  }

  // static Future onUpgrade(
  //   Batch batch,
  //   int oldVersion,
  //   int newVersion,
  //   BuildContext context,
  // ) async {
  //   if (oldVersion == 1 && newVersion == 2) _migrate_1to2(batch, context);
  // }

  // static Future onDowngrade(
  //   Batch batch,
  //   int oldVersion,
  //   int newVersion,
  //   BuildContext context,
  // ) async {
  //   if (oldVersion == 2 && newVersion == 1) _migrate_2to1(batch, context);
  // }

  Future<List<ChecklistSection>> getChecklistSections() async {
    Database db = await DB.instance.database;

    List<Map<String, dynamic>> dbSections = await db.rawQuery('''
      SELECT $tableChecklistSections.*,
      (
        SELECT COUNT()
        FROM $tableChecklistItems
        WHERE $tableChecklistItems.$columnItemSectionGuid = $tableChecklistSections.$columnSectionGuid
      ) AS itemsTotal,
      (
        SELECT COUNT()
        FROM $tableChecklistItems
        WHERE $tableChecklistItems.$columnItemSectionGuid = $tableChecklistSections.$columnSectionGuid
        AND $tableChecklistItems.$columnItemChecked = 1
      ) AS itemsChecked
      FROM $tableChecklistSections
      ORDER BY $columnSectionPosition;
    ''');

    return dbSections.map((section) => ChecklistSection.fromDBMap(section)).toList();
  }

  Future<List<ChecklistItem>> getChecklistItems(String sectionGuid) async {
    Database db = await DB.instance.database;

    List<Map<String, dynamic>> dbItems = await db.query(
      tableChecklistItems,
      where: '$columnItemSectionGuid = "$sectionGuid"',
      orderBy: columnItemName,
    );

    return dbItems.map((item) => ChecklistItem.fromDBMap(item)).toList();
  }

  Future<int> updateItem(ChecklistItem item) async {
    Database db = await DB.instance.database;

    return await db.update(
      tableChecklistItems,
      item.toDBMap(),
      where: '$columnItemGuid = "${item.guid}"',
    );
  }
}

// -- MIGRATIONS --------------------------------------------------------------

// void _migrate_1to2(Batch batch, BuildContext context) async {
//   Map<String, dynamic> json = await _fetchJSON(context);
//   List<dynamic> checklist = json['data']['sections'];

//   batch.insert(
//     tableVersions,
//     {columnVersionsSection: 'checklist', columnVersionsVersion: json['version']},
//   );

//   _overrideNames(batch, checklist);
// }

// void _migrate_2to1(Batch batch, BuildContext context) async {
//   Map<String, dynamic> json = await _fetchJSON(context);
//   List<dynamic> checklist = json['data']['sections'];

//   _overrideNames(batch, checklist);
// }

// void _overrideNames(batch, checklist) {
//   checklist.forEach((section) {
//     section['items'].forEach((item) {
//       batch.update(
//         tableChecklistItems,
//         {columnItemName: item['name']},
//         where: 'guid = ?',
//         whereArgs: [item['guid']],
//       );
//     });
//   });
// }
