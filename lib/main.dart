import 'package:flutter/material.dart';

import 'frame.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String appTitle = 'Adventure Companion';

    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: Color.fromRGBO(34, 53, 81, 1),
      ),
      debugShowCheckedModeBanner: false,
      home: Frame(),
    );
  }
}
