import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/colors/colors.dart';
import 'package:todo/models/tag_model.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/provider/todo_provider.dart';
import 'package:todo/screens/add_todo.dart';
import 'package:todo/widgets/categories_card.dart';
import 'package:todo/widgets/svg_icon.dart';
import 'package:todo/widgets/tasks_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<TagModel> list = [
    TagModel(tag: 'Personal', completeTasks: 18, tasks: 45),
    TagModel(tag: 'Business', completeTasks: 16, tasks: 22),
    TagModel(tag: 'Study', completeTasks: 1, tasks: 12),
    TagModel(tag: 'Coding', completeTasks: 25, tasks: 25),
    TagModel(tag: 'Othets', completeTasks: 12, tasks: 18),
  ];

  // List<TodoModel> todos = [];

  @override
  void initState() {
    super.initState();
  }

  Widget headerIcons() {
    return Row(
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
            // const SizedBox(
            //   height: 16,
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child:
                  SizedBox(height: 100, child: Expanded(child: listOfTags())),
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
            Expanded(child: listOfTasks(todos))
          ],
        ),
      )),
    );
  }
}
