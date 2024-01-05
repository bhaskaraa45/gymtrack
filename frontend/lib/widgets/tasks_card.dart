import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/colors/colors.dart';
import 'package:todo/models/todo_model.dart';

class TasksCard extends StatefulWidget {
  const TasksCard({super.key, required this.color, required this.todo});
  final Color color;
  final TodoModel todo;

  @override
  State<TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends State<TasksCard> {
  bool isDone = false;

  Widget checkBox() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            isDone = true;
          });
        },
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: widget.color, width: 3)),
        ),
      ),
    );
  }

  Widget completeCheckBox() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            isDone = false;
          });
        },
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 30,
          width: 30,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: MyColors().primary3),
          child: Icon(
            Icons.done_rounded,
            size: 26,
            color: MyColors().textColor,
          ),
        ),
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    if (DateTime.now().day == dateTime.day &&
        DateTime.now().month == dateTime.month &&
        DateTime.now().year == dateTime.year) {
      return DateFormat('hh:mm a').format(dateTime);
    } else {
      return DateFormat('hh:mm a, dd MMM yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 72,
      decoration: BoxDecoration(
          color: MyColors().primary2, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
          ),
          isDone ? completeCheckBox() : checkBox(),
          const SizedBox(
            width: 20,
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.todo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: MyColors().textColor,
                      fontSize: 20,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: MyColors().textColor,
                      decorationThickness: 2,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  formatDateTime(widget.todo.time),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: MyColors().secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
