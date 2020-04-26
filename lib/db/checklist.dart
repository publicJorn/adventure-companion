import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import './database.dart';

final String tableChecklistSections = 'checklist_sections';
final String columnSectionGuid = 'guid';
final String columnSectionPosition = 'position';
final String columnSectionName = 'name';
final String columnSectionInfo = 'info';

final String tableChecklistItems = 'checklist_items';
final String columnItemGuid = 'guid';
final String columnItemSectionGuid = 'sectionGuid';
final String columnItemPosition = 'position';
final String columnItemName = 'name';
final String columnItemInfo = 'info';
final String columnItemChecked = 'checked';

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

// ----------------------------------------------------------------------------

class DBChecklist {
  Database db;

  DBChecklist._singleton();
  static final DBChecklist _instance = DBChecklist._singleton();

  factory DBChecklist() {
    return _instance;
  }

  static Future onCreate(Database db, int version, BuildContext context) async {
    // Fetch content from JSON
    // OPTIMIZE: combine with json_serializable
    String data = await DefaultAssetBundle.of(context).loadString('content/checklist.json');

    List<dynamic> checklist = json.decode(data)['data']['sections'];

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
      orderBy: columnItemPosition,
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
