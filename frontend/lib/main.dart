import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/colors/colors.dart';
import 'package:todo/firebase_options.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/provider/todo_provider.dart';
import 'package:todo/screens/home.dart';
import 'package:todo/services/api_services.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.

  fetchAllTodos() async {
    List<TodoModel> todos =
        await ApiService().getAllTodos('bhaskar'); //TODO: change user id
    ref.read(todoProvider.notifier).addAllTodo(todos);
  }

  @override
  void initState() {
    super.initState();
    fetchAllTodos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MyColors().primary),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
