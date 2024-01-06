import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/colors/colors.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  TextEditingController titleController = TextEditingController();

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
          onTap: () {
            //TODO: API CALL
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      // backgroundColor: MyColors().primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              textFieldWidget('What do you need to do?', titleController, 1),
              const SizedBox(
                height: 16,
              ),
              textFieldWidget('Description', titleController, 3),
              const SizedBox(
                height: 16,
              ),
              // addTags()
              dateTimeWidget(),
              const SizedBox(
                height: 20,
              ),
              finalTagWidget(),
              const SizedBox(
                height: 32,
              ),
              Align(child: addTask(size)),
              const SizedBox(
                height: 40,
              ),
            ],
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
