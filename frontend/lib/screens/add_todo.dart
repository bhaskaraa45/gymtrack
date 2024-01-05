import 'package:flutter/material.dart';
import 'package:todo/colors/colors.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  TextEditingController titleController = TextEditingController();

  Widget addTags(){
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors().purple,width: 1)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Tags: ',
              style: TextStyle(
                color: MyColors().secondary,
                fontSize: 18,
                fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
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
              height: 8,
            ),
            textFieldWidget('Description', titleController, 3),
            const SizedBox(
              height: 8,
            ),
            addTags()
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
