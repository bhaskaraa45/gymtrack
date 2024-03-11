import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo/colors/colors.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/provider/todo_provider.dart';
import 'package:todo/services/api_services.dart';

class TasksCard extends ConsumerStatefulWidget {
  const TasksCard({super.key, required this.color, required this.todo});
  final Color color;
  final TodoModel todo;

  @override
  ConsumerState<TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends ConsumerState<TasksCard> {
  bool isDone = false;

  updateDoneStatus(bool value) async {
    setState(() {
      isDone = value;
    });
    TodoModel todoModel = widget.todo;
    todoModel.isDone = value;
    bool result = await ApiService().updateTodo(todoModel, todoModel.id ?? 0);
    if (!result) {
      // showToast("Something went wrong!");
      setState(() {
        isDone = !value;
      });
    }
  }

  // showToast(String msg) {
  //   Fluttertoast.showToast(
  //       msg: msg,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }

  deleteTodo() async {
    bool result = await ApiService().deleteTodoByID(widget.todo.id ?? 0);
    if (result) {
      ref.read(todoProvider.notifier).removeTodo(widget.todo);
    } else {
      // showToast("Something went wrong!");
    }
  }

  Widget checkBox() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // setState(() {
          //   isDone = true;
          // });
          updateDoneStatus(true);
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
          // setState(() {
          //   isDone = false;
          // });
          updateDoneStatus(false);
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
  void initState() {
    super.initState();
    setState(() {
      isDone = widget.todo.isDone;
    });
  }

  void _showPopupMenu(BuildContext context, LongPressStartDetails details) {
    // Get the tap position
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset tapPosition = overlay.globalToLocal(details.globalPosition);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 40,
        tapPosition.dy + 40,
      ),
      items: <PopupMenuEntry>[
        // PopupMenuItem(
        //   value: 'edit',
        //   child: Text('edit',
        //       style: TextStyle(color: MyColors().primary3, fontSize: 16)),
        // ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'delete',
            style: TextStyle(color: MyColors().primary3, fontSize: 16),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        // Handle edit action
      } else if (value == 'delete') {
        deleteTodo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showPopupMenu(context, details);
      },
      child: Container(
        width: double.infinity,
        height: 72,
        decoration: BoxDecoration(
            color: MyColors().primary2,
            borderRadius: BorderRadius.circular(18)),
        child: Material(
          color: Colors.transparent,
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
        ),
      ),
    );
  }
}
