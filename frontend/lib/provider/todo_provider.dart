import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/models/todo_model.dart';

final todoProvider = StateNotifierProvider<TodoNotifier, List<TodoModel>>(
    (ref) => TodoNotifier());

class TodoNotifier extends StateNotifier<List<TodoModel>> {
  TodoNotifier() : super([]);

  void addTodo(TodoModel todo) {
    state = [...state, todo];
  }

  void addAllTodo(List<TodoModel> todos) {
    state = [...state, ...todos];
  }

  void removeTodo(TodoModel todo) {
    state = state.where((item) => item != todo).toList();
  }
}
