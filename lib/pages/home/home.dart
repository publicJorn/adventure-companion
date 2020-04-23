import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adventure Companion'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 8),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Adventure Companion helpt jou om overal op voorbereid te zijn tijdens je volgende trip!\n',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Deze app wordt aangeboden door\nAdventure Shield.',
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: SvgPicture.asset(
                      'assets/logo_adventure_shield.svg',
                      matchTextDirection: true,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'App realisatie: frontrain.net',
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ],
        ),
      ),
    );
  }
}
