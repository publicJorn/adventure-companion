import 'package:flutter/material.dart';
// import 'dart:convert';

import '../../db_helpers.dart';
import 'section_list.dart';
import 'items_list.dart';

class ChecklistPage extends StatefulWidget {
  ChecklistPage({Key key}) : super(key: key);

  @override
  ChecklistPageState createState() => ChecklistPageState();
}

class ChecklistPageState extends State<ChecklistPage> {
  DB db;
  List<ChecklistSection> _sections = new List();
  List<ChecklistItem> _items;
  int _selectedSectionId;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    db = DB(context: context);

    _loadSections();
    _pageController = PageController(
      initialPage: _selectedSectionId ?? 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: _selectedSectionId == null ? 16.0 : 0.0,
        title: _makeTitle(),
        actions: _makeAppBarAction(),
      ),
      body: _makeBody(),
    );
  }

  Widget _makeTitle() {
    if (_selectedSectionId == null) return Text('Checklist');

    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _setSelectedSection('');
          },
        ),
        Expanded(
          child: Text(_sections[_selectedSectionId].name),
        ),
      ],
    );
  }

  List<Widget> _makeAppBarAction() {
    if (_selectedSectionId != null && _sections[_selectedSectionId].info.isNotEmpty) {
      return [
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            _showSectionInfo();
          },
        ),
      ];
    }

    return null;
  }

  Widget _makeBody() {
    if (_sections.isEmpty) return Container();

    return PageView.builder(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (BuildContext context, int i) {
        if (i == 0) return SectionList(_sections, _setSelectedSection);

        if (_selectedSectionId == null) return Container();

        return ItemsList(_items, _toggleItem);
      },
    );
  }

  void _loadSections() async {
    List<ChecklistSection> sections = await db.getChecklistSections();

    setState(() {
      _sections = sections;
    });
  }

  Future<List<ChecklistItem>> _loadItems(String guid, {bool updateState = true}) async {
    List<ChecklistItem> items = await db.getChecklistItems(guid);

    if (updateState) {
      setState(() {
        _items = items;
      });
    }

    return items;
  }

  void _setSelectedSection(String guid) async {
    int sectionId = _sections.indexWhere((section) => section.guid == guid);

    // When animating TO items, set state immediately
    if (guid.isNotEmpty) {
      List<ChecklistItem> items = await _loadItems(guid, updateState: false);

      setState(() {
        _items = items;
        _selectedSectionId = sectionId;
      });
    }

    // When animating TO sections make sure to update the list first
    if (guid.isEmpty) {
      setState(() {
        _loadSections();
      });
    }

    await _pageController.animateToPage(
      guid.isEmpty ? 0 : 1,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInSine,
    );

    // When animating FROM items, await animation completion (above) before clearing contents
    if (guid.isEmpty) {
      setState(() {
        _items = null;
        _selectedSectionId = null;
      });
    }
  }

  void _showSectionInfo() {
    ChecklistSection section = _sections[_selectedSectionId];

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(section.name),
            content: Text(section.info),
            actions: <Widget>[
              FlatButton(
                child: Text('Oké'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _toggleItem(ChecklistItem item) async {
    int id;

    item.isChecked = !item.isChecked;
    id = await db.updateItem(item);

    if (id > -1) {
      _loadItems(item.sectionGuid);
    }
  }
}
