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

  List<String> tags = ['Personal', 'Business', 'Study', 'Coding', 'Others'];

  List<String> selectedTags = [
    'Personal',
    'Business',
    'Study',
    'Coding',
    'Others'
  ];

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
      return DateFormat('hh:mm a').format(dateTime);
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

  Widget oneTag(String tag) {
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
                onTap: () {},
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

  // Widget addTags() {
  //   return Container(
  //     width: double.infinity,
  //     height: 60,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       // border: Border.all(color: MyColors().purple, width: 1)
  //     ),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(12.0),
  //           child: Text(
  //             'Tags: ',
  //             style: TextStyle(
  //                 color: MyColors().secondary,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w400),
  //           ),
  //         ),
  //         Wrap(
  //           crossAxisAlignment: WrapCrossAlignment.start,
  //           children: listOfTagsWidget(),
  //         ),
  //         const SizedBox(
  //           width: 20,
  //         ),
  //         addTagButton()
  //       ],
  //     ),
  //   );
  // }

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
          onTap: () {},
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
        Container(
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
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Center(
                  child: Text(
                    time,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors().primary,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      )),
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
