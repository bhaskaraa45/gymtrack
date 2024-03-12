import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtrack/colors/colors.dart';
import 'package:gymtrack/main.dart';
import 'package:gymtrack/models/tag_model.dart';
import 'package:gymtrack/models/todo_model.dart';
import 'package:gymtrack/provider/todo_provider.dart';
import 'package:gymtrack/screens/add_todo.dart';
import 'package:gymtrack/screens/drawer.dart';
import 'package:gymtrack/widgets/categories_card.dart';
import 'package:gymtrack/widgets/svg_icon.dart';
import 'package:gymtrack/widgets/tasks_card.dart';
import 'package:gymtrack/widgets/which_day.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<TagModel> list = [
    TagModel(tag: 'Back', completeTasks: 3, date: "10/03/2024", tasks: 3),
    TagModel(tag: 'Legs', completeTasks: 2, date: "11/03/2024", tasks: 3),
    TagModel(tag: 'Shoulder', completeTasks: 3, date: "12/03/2024", tasks: 3),
    TagModel(tag: 'Arms', completeTasks: 1, date: "13/03/2024", tasks: 3),
    TagModel(tag: 'Chest', completeTasks: 3, date: "14/03/2024", tasks: 3),
  ];

  // List<TodoModel> todos = [];

  @override
  void initState() {
    super.initState();
  }

  Widget headerIcons(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (BuildContext scaffoldContext) {
            return InkWell(
              onTap: () {
                Scaffold.of(scaffoldContext).openDrawer();
              },
              borderRadius: BorderRadius.circular(36),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: SvgIcon(
                  "assets/icons/menu.svg",
                  size: 20,
                ),
              ),
            );
          },
        ),
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
          return Container(
            margin: EdgeInsets.only(right: 24),
            child: CategoriesCard(
                date: list[index].date,
                tag: list[index].tag,
                percentage: percentage,
                color: index % 2 == 0 ? MyColors().blue : MyColors().purple),
          );
        });
  }

  Widget listOfTasks(List<TodoModel> todos) {
    return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (ctx, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: TasksCard(
                color: index % 2 == 0 ? MyColors().blue : MyColors().purple,
                todo: todos[index]),
          );
        });
  }

  Widget floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Navigator.push(context, CustomPageRoute(child: const  AddTodoScreen(),startPos: const Offset(0, 1)));
        showModalBottomSheet(
            backgroundColor: MyColors().primary,
            context: context,
            builder: (ctx) => const AddTodoScreen());
      },
      backgroundColor: MyColors().purple,
      child: Icon(
        Icons.add_rounded,
        size: 36,
        color: MyColors().primary2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TodoModel> todos = ref.watch(todoProvider);
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: MyColors().primary),
      ),
      floatingActionButton: floatingActionButton(),
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
            headerIcons(context),
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
                'HISTORY',
                style: TextStyle(
                    letterSpacing: -0.2,
                    color: MyColors().secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            ),
            // const SizedBox(
            //   height: 16,
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                  height: 100,
                  child: Expanded(child: listOfTags())), //TODO:look
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
            const Center(child: WhichDay(title: "BACK DAY")),
            Expanded(child: listOfTasks(todos))
          ],
        ),
      )),
    );
  }
}
