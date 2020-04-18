import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  final String homeText = '''
Adventure Companion helpt jou om overal op voorbereid te zijn tijdens je volgende trip!

Deze app is nog in ontwikkeling. Meer content word ooit toegevoegd. 🙂
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adventure Companion'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              homeText,
              style: TextStyle(fontSize: 16),
            ),
            SvgPicture.asset(
              'assets/logo-adventure-shield.svg',
              // color: Color.fromRGBO(15, 169, 138, 1),
              matchTextDirection: true,
            )
          ],
        ),
      ),
    );
  }
}
