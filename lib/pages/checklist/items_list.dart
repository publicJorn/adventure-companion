import 'package:flutter/material.dart';

class ItemsList extends StatelessWidget {
  final Map items;
  final String section;

  ItemsList(this.items, this.section);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int i) {
        String guid = items.keys.elementAt(i);
        String name = items[guid]['name'];

        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  // This child fills available space
                  child: ListTile(
                    title: Text(name),
                    onTap: () {
                      _setSelected(guid);
                    },
                  ),
                ),
                Icon(
                  Icons.check_box_outline_blank,
                  color: Theme.of(context).disabledColor,
                ),
              ],
            ),
            Divider(
              color: Theme.of(context).primaryColor.withAlpha(80),
              height: 1,
            ),
          ],
        );
      },
    );
  }

  void _setSelected(guid) {
    print('Set this one selected: $guid');
  }
}
