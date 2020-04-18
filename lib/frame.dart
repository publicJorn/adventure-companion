import 'package:flutter/material.dart';

import 'pages/home/home.dart';
import 'pages/checklist/checklist.dart';

class Frame extends StatefulWidget {
  Frame({Key key}) : super(key: key);

  @override
  FrameState createState() => FrameState();
}

class FrameState extends State<Frame> {
  int _currentPageId = 0;
  PageController _pageController;

  final List<Widget> _pages = [
    HomePage(),
    ChecklistPage(),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: _currentPageId,
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
      bottomNavigationBar: _bottomNav(),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      onTap: _navigateTo,
      currentIndex: _currentPageId,
      selectedItemColor: Color.fromRGBO(15, 169, 138, 1),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_add_check),
          title: Text('Checklist'),
        ),
      ],
    );
  }

  void _navigateTo(int index) {
    setState(() {
      _pageController.jumpToPage(index);
      _currentPageId = index;
    });
  }
}
