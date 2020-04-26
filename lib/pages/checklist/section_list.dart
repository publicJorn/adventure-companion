import 'package:flutter/material.dart';

import 'package:adventure_companion/db/checklist.dart';

class SectionList extends StatelessWidget {
  final List<ChecklistSection> sections;
  final Function setSelectedSection;

  SectionList(this.sections, this.setSelectedSection);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (BuildContext context, int i) {
        ChecklistSection section = sections[i];
        String sectionText = '${section.name} (${section.itemsChecked}/${section.itemsTotal})';

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
