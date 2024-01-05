import 'package:flutter/material.dart';
import 'package:todo/colors/colors.dart';
import 'package:todo/models/tag_model.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/widgets/categories_card.dart';
import 'package:todo/widgets/svg_icon.dart';
import 'package:todo/widgets/tasks_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TagModel> list = [
    TagModel(tag: 'Personal', completeTasks: 18, tasks: 45),
    TagModel(tag: 'Business', completeTasks: 16, tasks: 22),
    TagModel(tag: 'Study', completeTasks: 1, tasks: 12),
    TagModel(tag: 'Coding', completeTasks: 25, tasks: 25),
    TagModel(tag: 'Othets', completeTasks: 12, tasks: 18),
  ];

TodoModel todoModel = TodoModel(id: 10, title: "Do one dsa question", description: "1", isDone: false, tag: "tag", User: "bhaskar", time: DateTime.now());

  Widget headerIcons() {
    return Container(
      // color: Colors.amber,
      child: Row(
        children: [
          InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(36),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: SvgIcon(
                  "assets/icons/menu.svg",
                  size: 20,
                ),
              )),
          const Spacer(),
          InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(36),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: SvgIcon(
                  "assets/icons/search-normal.svg",
                  size: 28,
                ),
              )),
          const SizedBox(
            width: 16,
          ),
          InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(36),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: SvgIcon(
                  "assets/icons/user.svg",
                  size: 30,
                ),
              )),
        ],
      ),
    );
  }

  Widget greeting(String name) {
    return Text(
      'What\'s up, $name!',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: MyColors().textColor,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3),
    );
  }

  Widget listOfTags() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (ctx, index) {
          double percentage =
              (list[index].completeTasks * 100.0) / list[index].tasks;
          print(percentage);
          return Container(
            margin: EdgeInsets.only(right: 24),
            child: CategoriesCard(
                tasks: list[index].tasks,
                tag: list[index].tag,
                percentage: percentage,
                color: index % 2 == 0 ? MyColors().blue : MyColors().purple),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors().primary,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 24,
            ),
            headerIcons(),
            const SizedBox(
              height: 26,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: greeting('Bhaskar'),
            ),
            const SizedBox(
              height: 26,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'CATEGORIES',
                style: TextStyle(
                    letterSpacing: -0.2,
                    color: MyColors().secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                height: 100 ,
                child: Expanded(child: listOfTags())),
            ),
            const SizedBox(
              height: 36,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'TODAY\'S TASKS',
                style: TextStyle(
                    letterSpacing: -0.2,
                    color: MyColors().secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            ),
            
            TasksCard(color: MyColors().purple,todo: todoModel,)
          ],
        ),
      )),
    );
  }
}
