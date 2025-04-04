import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class UserRepository {
  final String baseUrl = 'https://reqres.in/api';

  Future<UserResponse> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users?per_page=12'));
      if (response.statusCode == 200) {
        return UserResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<UserDetailResponse> getUserById(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserDetailResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      throw Exception('Failed to load user details: $e');
    }
  }
}
