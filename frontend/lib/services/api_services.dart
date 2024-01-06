import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:todo/models/todo_model.dart';

class ApiService {
  String backendIp = "${dotenv.env['backendIp']!}:${dotenv.env['port']!}";

  Future<List<TodoModel>> getAllTodos(String userId) async {
    final response = await http.get(
      Uri.parse('$backendIp/todos/$userId'),
    );

    print(response.body);

    if (response.statusCode < 300) {
      List<dynamic> jsonResponse = jsonDecode(response.body);

      List<TodoModel> todos = jsonResponse.map((todoJson) {
        return TodoModel(
          id: todoJson['id'],
          title: todoJson['title'],
          description: todoJson['description'],
          isDone: todoJson['isDone'],
          tags: todoJson['tag'],
          User: todoJson['user'],
          time: DateTime.parse(todoJson['time']),
        );
      }).toList();
      return todos;
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<TodoModel> getTodoByTODOId(int id) async {
    final response = await http.get(
      Uri.parse('$backendIp/todo/$id'),
    );

    print(response.body);

    if (response.statusCode < 300) {
      var jsonResponse = jsonDecode(response.body);

      return TodoModel(
        id: jsonResponse['id'],
        title: jsonResponse['title'],
        description: jsonResponse['description'],
        isDone: jsonResponse['isDone'],
        tags: jsonResponse['tag'],
        User: jsonResponse['user'],
        time: DateTime.parse(jsonResponse['time']),
      );
    } else {
      throw Exception('Failed to load todo by ID');
    }
  }

  Future<bool> deleteTodoByID(int id) async {
    final response = await http.delete(
      Uri.parse('$backendIp/todo/$id'),
    );

    print(response.body);

    if (response.statusCode < 300) {
      return true;
    } else {
      throw Exception('Failed to delete todo by ID');
    }
  }

  Future<int?> addTodo(TodoModel todo) async {
    final response = await http.post(Uri.parse('$backendIp/todo'),
        body: jsonEncode({
          "title": todo.title,
          "description": todo.description,
          "isDone": todo.isDone,
          "tags": todo.tags,
          "User": todo.User,
          "time": todo.time.toIso8601String(),
        }));

    print(response.body);

    if (response.statusCode < 300) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['id'];
    } else {
      throw Exception('Failed to add todo');
    }
  }

  Future<bool> updateTodo(TodoModel todo, int id) async {
    final response = await http.post(Uri.parse('$backendIp/todo/$id'),
        body: jsonEncode({
          "title": todo.title,
          "description": todo.description,
          "isDone": todo.isDone,
          "tags": todo.tags,
          "User": todo.User,
          "time": todo.time.toIso8601String(),
        }));

    print(response.body);

    if (response.statusCode < 300) {
      return true;
    } else {
      throw Exception('Failed to update todo');
    }
  }
}
