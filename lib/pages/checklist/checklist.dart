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
  Future<List<ChecklistItem>> _itemsFuture;
  int _selectedSectionId;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    // TODO: preload when app starts up
    _loadChecklist(context);
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

  Widget _makeBody() {
    if (_sections.isEmpty) return Container();

    return PageView.builder(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (BuildContext context, int i) {
        if (i == 0) return SectionList(_sections, _setSelectedSection);

        if (_selectedSectionId == null) return Container();

        return ItemsList(_itemsFuture, _toggleItem);
      },
    );
  }

  void _loadChecklist(context) async {
    db = DB(context: context);

    List<ChecklistSection> sections = await db.getChecklistSections();

    setState(() {
      _sections = sections;
    });
  }

  void _setSelectedSection(String guid) async {
    int sectionId = _sections.indexWhere((section) => section.guid == guid);

    // When animating TO items, set section immediately
    if (guid.isNotEmpty) {
      setState(() {
        _itemsFuture = db.getChecklistItems(guid);
        _selectedSectionId = sectionId;
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
        _itemsFuture = null;
        _selectedSectionId = null;
      });
    }
  }

  void _toggleItem(ChecklistItem item) async {
    int id;

    item.isChecked = !item.isChecked;
    id = await db.updateItem(item);

    // TODO: better check and error handling
    // OPTIMIZE: don't update whole list - see if we can update only the one item
    if (id > -1) {
      _itemsFuture = db.getChecklistItems(item.guid);
    }
  }
}
