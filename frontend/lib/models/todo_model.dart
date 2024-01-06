// ignore_for_file: non_constant_identifier_names

class TodoModel {
  final int id;
  final String title;
  final String description;
  final bool isDone;
  final String tag;
  final String User;
  final DateTime time;

  TodoModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.isDone,
      required this.tag,
      required this.User,
      required this.time});
}
