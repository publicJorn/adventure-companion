import 'package:flutter/material.dart';

class SectionList extends StatelessWidget {
  final Map checklist;
  final Function setSelectedSection;

  // OPTIMIZE: passing setSelectedSection be done using InheritedWidget
  SectionList(this.checklist, this.setSelectedSection);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: checklist.length,
      itemBuilder: (BuildContext context, int i) {
        String section = checklist.keys.elementAt(i);
        int subItemsTotal = checklist[section]['list'].keys.length;
        String title = '$section (?/$subItemsTotal)';

        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  // This child fills available space
                  child: ListTile(
                    title: Text(title),
                    onTap: () {
                      setSelectedSection(section);
                    },
                  ),
                ),
                Icon(
                  Icons.chevron_right,
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
}
