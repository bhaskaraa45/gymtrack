// ignore_for_file: non_constant_identifier_names

class TodoModel {
  int? id;
  String title;
  String? description;
  bool isDone;
  String? tag;
  String User;
  DateTime time;

  TodoModel(
      {this.id,
      required this.title,
      this.description,
      required this.isDone,
      this.tag,
      required this.User,
      required this.time});
}
