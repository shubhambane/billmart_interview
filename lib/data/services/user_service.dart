import 'dart:convert';

import 'package:billmart_interview/data/models/pagination_params.dart';
import 'package:billmart_interview/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String _baseUrl = 'https://reqres.in/api';

  Future<UserResponse> getUsers({required PaginationParams params}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users').replace(
          queryParameters: {
            'page': params.page.toString(),
            'per_page': params.perPage.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        return UserResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
}
