import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String backendEp = "${dotenv.env['BACKEND_EP']}";

  login(String idToken) async {
    try {
      final response = await http.post(Uri.parse("$backendEp/auth"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"idToken": idToken}));

      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
