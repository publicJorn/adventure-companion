// // TODO: check out later
// import 'package:json_annotation/json_annotation.dart';

// part 'models.g.dart';

// @JsonSerializable()
// class ChecklistItem {
//   String guid;
//   String name;
//   String info;

//   ChecklistItem({this.guid, this.name, this.info});

//   factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
//       _$ChecklistItemFromJson(json);

//   Map<String, dynamic> toJson() => _$ChecklistItemToJson(this);
// }

// @JsonSerializable()
// class ChecklistSection {
//   String name;
//   List<ChecklistItem> items;

//   ChecklistSection({this.name, this.items});
// }

// @JsonSerializable()
// class Checklist {
//   List<ChecklistSection> sections;

//   Checklist({this.sections});
// }
