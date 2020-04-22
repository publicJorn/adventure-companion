import 'package:adventure_companion/db_helpers.dart';
import 'package:flutter/material.dart';

class ItemsList extends StatelessWidget {
  final Future<List<ChecklistItem>> itemsFuture;
  final Function toggleItem;

  ItemsList(this.itemsFuture, this.toggleItem);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: itemsFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<ChecklistItem>> snapshot,
      ) {
        Widget child;

        if (snapshot.hasData) {
          child = _buildItemsList(snapshot.data);
        } else if (snapshot.hasError) {
          print('ERROR: loading checklist items =>\n${snapshot.error}');
          child = Container(child: Text('Error loading checklist items'));
        } else {
          child = Container(); // Loading...
        }

        return child;
      },
    );
  }

  _buildItemsList(List<ChecklistItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int i) {
        ChecklistItem item = items[i];

        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  // This child fills available space
                  child: ListTile(
                    title: Text(item.name),
                    onTap: () {
                      toggleItem(item);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    toggleItem(item);
                  },
                  icon: Icon(item.isChecked
                      ? Icons.check_box
                      : Icons.check_box_outline_blank),
                  color: item.isChecked
                      ? Colors.lightGreen
                      : Theme.of(context).disabledColor,
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
}
