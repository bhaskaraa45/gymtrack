import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo/colors/colors.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/provider/todo_provider.dart';
import 'package:todo/services/api_services.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  const AddTodoScreen({super.key});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<String> tags = [
    'Personal',
    'Business',
    'Study',
    'Coding',
    'Others',
  ];
  List<bool> selected = List.generate(5, (index) => false);

  List<String> selectedTags = [];

  bool isCustomClicked = false;
  TextEditingController customTagController = TextEditingController();

  String time = '12:00 AM';
  // DateTime selectedTime = DateTime.now();
  @override
  void initState() {
    super.initState();
    setState(() {
      time = formatDateTime(_selectedDateTime);
    });
  }

  String formatDateTime(DateTime dateTime) {
    if (DateTime.now().day == dateTime.day &&
        DateTime.now().month == dateTime.month &&
        DateTime.now().year == dateTime.year) {
      return 'Today, ${DateFormat('hh:mm a').format(dateTime)}';
    } else {
      return DateFormat('hh:mm a, dd MMM yyyy').format(dateTime);
    }
  }

  DateTime _selectedDateTime = DateTime.now();

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDateTime) {
      TimeOfDay initialTime = TimeOfDay(
          hour: _selectedDateTime.hour, minute: _selectedDateTime.minute);
      // ignore: use_build_context_synchronously
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
        setState(() {
          time = formatDateTime(_selectedDateTime);
        });
      }
    }
  }

  Widget oneTag(
    String tag,
  ) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4, right: 4),
          width: 120,
          height: 40,
          decoration: BoxDecoration(
              color: MyColors().secondary,
              borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(
              tag,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: MyColors().primary2,
                  fontWeight: FontWeight.w500,
                  fontSize: 17),
            ),
          ),
        ),
        Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: MyColors().textColor),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  if (selectedTags.contains(tag)) {
                    int index = tags.indexOf(tag);
                    setState(() {
                      selectedTags.remove(tag);
                      selected[index] = false;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(36),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: MyColors().purple,
                )),
          ),
        )
      ],
    );
  }

  List<Widget> listOfTagsWidget() {
    List<Widget> list = List.generate(
      selectedTags.length,
      (index) => oneTag(selectedTags[index]),
    );
    return list;
  }

  Widget finalTagWidget() {
    List<Widget> list = listOfTagsWidget();
    list.insert(
      0,
      Container(
        margin: const EdgeInsets.fromLTRB(14, 12, 0, 7),
        child: Text(
          'Tags: ',
          style: TextStyle(
              color: MyColors().secondary,
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ),
      ),
    );

    list.add(addTagButton());

    return Wrap(
      children: list,
    );
  }

  Widget showTagAddingDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: MyColors().secondary,
      title: const Center(child: Text('Select tags')),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: listOfTagOptions(setState),
          );
        },
      ),
    );
  }

  listOfTagOptions(StateSetter setState) {
    List<Widget> list =
        List.generate(tags.length, (index) => tagOptionWidget(index, setState));
    list.add(customTagWidget(setState));
    list.add(doneButton());
    return list;
  }

  doneButton() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      alignment: Alignment.topRight,
      child: TextButton(
          onPressed: () {
            String tag = customTagController.text.trim();
            setState(() {
              isCustomClicked = false;
              customTagController.clear();
              if (tag.isNotEmpty &&
                  (!tags.contains(tag) && !selectedTags.contains(tag))) {
                selectedTags.add(tag);
                tags.add(tag);
                selected.add(true);
              }
            });
            Navigator.pop(context);
          },
          child: Text(
            'Done',
            style: TextStyle(color: MyColors().primary2),
          )),
    );
  }

  customTagWidget(StateSetter setState) {
    return Container(
      child: !isCustomClicked
          ? InkWell(
              onTap: () {
                setState(() {
                  isCustomClicked = !isCustomClicked;
                });
              },
              child: Text(
                'Add Custom',
                style: TextStyle(
                    color: MyColors().primary2,
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
            )
          : TextField(
              controller: customTagController,
              style: TextStyle(
                  color: MyColors().primary2,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: MyColors().primary, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: MyColors().primary, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: MyColors().primary3, width: 2.5)),
              ),
            ),
    );
  }

  tagOptionWidget(int index, StateSetter setState) {
    return Row(
      children: [
        Checkbox(
          value: selected[index],
          onChanged: (value) {
            setState(() {
              selected[index] = value!;
            });
            changeValues(index, selected[index]);
          },
        ),
        Flexible(
            child: Text(
          tags[index],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: MyColors().primary2,
              fontSize: 17,
              fontWeight: FontWeight.w500),
        ))
      ],
    );
  }

  changeValues(int index, bool value) {
    setState(() {
      if (value) {
        selectedTags.add(tags[index]);
      } else {
        selectedTags.remove(tags[index]);
      }
    });
  }

  addTagButton() {
    return Container(
      height: 40,
      width: 72,
      margin: const EdgeInsets.only(top: 4, right: 12, left: 14),
      decoration: BoxDecoration(
          color: MyColors().secondary, borderRadius: BorderRadius.circular(14)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            showDialog(context: context, builder: showTagAddingDialog);
          },
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            Icons.add_rounded,
            size: 36,
            color: MyColors().sec,
          ),
        ),
      ),
    );
  }

  Widget dateTimeWidget() {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 6, 0, 6),
          child: Text(
            'Due Date-Time: ',
            style: TextStyle(
                color: MyColors().secondary,
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        Flexible(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: MyColors().secondary,
                borderRadius: BorderRadius.circular(12)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await selectDateTime(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    time,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: MyColors().primary2,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget addTask(Size size) {
    return Container(
      alignment: Alignment.topCenter,
      width: 180,
      height: 54,
      decoration: BoxDecoration(
        color: MyColors().primary2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            String title = titleController.text.trim();
            // if (title.isEmpty) {
            //   Fluttertoast.showToast(
            //       msg: "Please enter title of the task.",
            //       toastLength: Toast.LENGTH_SHORT,
            //       gravity: ToastGravity.CENTER,
            //       timeInSecForIosWeb: 1,
            //       textColor: Colors.white,
            //       fontSize: 16.0);
            //   return;
            // }

            TodoModel todo = TodoModel(
                title: title,
                description: descriptionController.text.trim(),
                isDone: false,
                User: 'bhaskar', //TODO: change USER
                time: _selectedDateTime,
                tags: selectedTags);

            // int? id = await ApiService().addTodo(todo);
            int id = 0;

            if (id != null) {
              todo.id = id;
              ref.read(todoProvider.notifier).addTodo(todo);
              if (mounted) {
                Navigator.pop(context);
              }
            } else {
              // Fluttertoast.showToast(
              //     msg: "Something went wrong!",
              //     toastLength: Toast.LENGTH_SHORT,
              //     gravity: ToastGravity.CENTER,
              //     timeInSecForIosWeb: 1,
              //     textColor: Colors.white,
              //     fontSize: 16.0);
              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Add Task',
              style: TextStyle(
                color: MyColors().textColor,
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int sets = 3;

  Widget setsWidget() {
    return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
        width: 164,
        height: 54,
        margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MyColors().purple, width: 1.5)),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  onTap: () {
                    if (sets <= 0) {
                      setState(() {
                        sets = 0;
                        reps.clear();
                      });
                    } else {
                      setState(() {
                        sets--;
                        reps.removeLast();
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: const Icon(
                    Icons.remove_rounded,
                    color: Colors.white,
                  )),
              Text(
                "Sets : $sets ",
                style: TextStyle(
                    letterSpacing: -0.2,
                    color: MyColors().textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18),
              ),
              InkWell(
                  onTap: () {
                    setState(() {
                      sets++;
                      setState(() {
                        reps.add(12);
                      });
                    });
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                  )),
            ],
          ),
        ));
  }

  List reps = [12, 12, 12];
  TextEditingController maxWt = TextEditingController();

  everySetReps(int i) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        // width: 210,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MyColors().purple, width: 0.5)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                onTap: () {
                  if (sets <= 0) {
                    setState(() {
                      reps[i - 1] = 0;
                    });
                  } else {
                    setState(() {
                      reps[i - 1]--;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(24),
                child: const Icon(
                  Icons.remove_rounded,
                  color: Colors.white,
                )),
            Text(
              "Set $i, Reps : ${reps[i - 1]} ",
              style: TextStyle(
                  letterSpacing: -0.2,
                  color: MyColors().textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18),
            ),
            InkWell(
                onTap: () {
                  setState(() {
                    reps[i - 1]++;
                  });
                },
                borderRadius: BorderRadius.circular(24),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                )),
          ],
        ));
  }

  listOfeverySetReps() {
    return ListView.builder(
        itemCount: reps.length,
        itemBuilder: (context, index) {
          return everySetReps(index + 1);
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
          // bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 4,
            ),
            height: 4,
            width: 64,
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(24)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                textFieldWidget(
                    'What exercise you need to do?', titleController, 1),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    setsWidget(),
                    Flexible(child: MaxWeight()),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Expanded(child: listOfeverySetReps()),
                const SizedBox(
                  height: 16,
                ),
                Align(child: addTask(size)),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget MaxWeight() {
    return Container(
      width: 164,
      height: 54,
      // padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Center(
        child: TextField(
          controller: maxWt,
          keyboardType: TextInputType.number,
          maxLines: 1,
          cursorColor: MyColors().secondary,
          style: TextStyle(
              color: MyColors().textColor,
              fontSize: 17,
              fontWeight: FontWeight.w300),
          decoration: InputDecoration(
            hintText: "Max weight",
            hintStyle: TextStyle(
              color: MyColors().secondary,
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: MyColors().purple, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: MyColors().purple, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: MyColors().purple, width: 2.5)),
          ),
        ),
      ),
    );
  }

  Widget textFieldWidget(
      String hint, TextEditingController controller, int maxLines) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: MyColors().secondary,
      style: TextStyle(
          color: MyColors().textColor,
          fontSize: 17,
          fontWeight: FontWeight.w300),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: MyColors().secondary,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MyColors().purple, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MyColors().purple, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MyColors().purple, width: 2.5)),
      ),
    );
  }
}
