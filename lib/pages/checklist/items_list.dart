import 'package:adventure_companion/db_helpers.dart';
import 'package:flutter/material.dart';

class ItemsList extends StatelessWidget {
  final List<ChecklistItem> items;
  final Function toggleItem;

  ItemsList(this.items, this.toggleItem);

  @override
  Widget build(BuildContext context) {
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
                    title: Container(
                      child: Text(item.name),
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                    ),
                    subtitle: item.info.isNotEmpty ? Text(item.info) : null,
                    onTap: () {
                      toggleItem(item);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    toggleItem(item);
                  },
                  icon: Icon(item.isChecked ? Icons.check_box : Icons.check_box_outline_blank),
                  color: item.isChecked
                      ? Color.fromRGBO(15, 169, 138, 1)
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
