class TagModel {
  final String tag;
  final String date;
  final int completeTasks;
  final int tasks;
  TagModel({required this.tag, required this.completeTasks,required this.date, this.tasks = 0});
}