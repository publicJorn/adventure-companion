import 'package:flutter/material.dart';
import 'dart:convert';

import 'section_list.dart';
import 'items_list.dart';

class ChecklistPage extends StatefulWidget {
  ChecklistPage({Key key}) : super(key: key);

  @override
  ChecklistPageState createState() => ChecklistPageState();
}

class ChecklistPageState extends State<ChecklistPage> {
  Map _checklist = new Map();
  String _selectedSection = '';
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    // TODO: preload when app starts up
    _loadChecklist(context);
    _pageController = PageController(
      initialPage: _selectedSection.isEmpty ? 0 : 1,
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
        titleSpacing: _selectedSection.isEmpty ? 16.0 : 0.0,
        title: _makeTitle(),
      ),
      body: _makeBody(),
    );
  }

  Widget _makeTitle() {
    if (_selectedSection.isEmpty) return Text('Checklist');

    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _setSelectedSection('');
          },
        ),
        Expanded(
          child: Text(_selectedSection),
        ),
      ],
    );
  }

  Widget _makeBody() {
    if (_checklist.length == 0) return Container();

    return PageView.builder(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (BuildContext context, int i) {
        if (i == 0) return SectionList(_checklist, _setSelectedSection);

        if (_selectedSection.isEmpty) return Container();

        return ItemsList(
          _checklist[_selectedSection]['list'],
          _selectedSection,
        );
      },
    );
  }

  void _loadChecklist(context) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('content/checklist.json');

    setState(() {
      // OPTIMIZE: use json_serializable
      _checklist = json.decode(data)['data'];
    });
  }

  void _setSelectedSection(String section) async {
    // When animating right, set section immediately
    if (section.isNotEmpty) {
      setState(() {
        _selectedSection = section;
      });
    }

    await _pageController.animateToPage(
      section.isEmpty ? 0 : 1,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInSine,
    );

    // When animating left, await animation completion (above) before clearing contents
    if (section.isEmpty) {
      setState(() {
        _selectedSection = '';
      });
    }
  }
}
