import 'package:adventure_companion/db_helpers.dart';
import 'package:flutter/material.dart';

class SectionList extends StatelessWidget {
  final List<ChecklistSection> sections;
  final Function setSelectedSection;

  SectionList(this.sections, this.setSelectedSection);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (BuildContext context, int i) {
        int checked = sections[i].itemsChecked;
        int total = sections[i].itemsTotal;
        String sectionText = '${sections[i].name} ($checked/$total)';

        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  // This child fills available space
                  child: ListTile(
                    title: Text(sectionText),
                    onTap: () {
                      setSelectedSection(sections[i].guid);
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
