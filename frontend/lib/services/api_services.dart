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
          tag: todoJson['tag'],
          User: todoJson['user'],
          time: DateTime.parse(todoJson['time']),
        );
      }).toList();
      return todos;
    } else {
      throw Exception('Failed to load todos');
    }
  }
}
