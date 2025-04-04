import 'package:billmart_interview/data/models/pagination_params.dart';
import 'package:billmart_interview/data/services/user_service.dart';
import 'package:billmart_interview/models/user_model.dart';

class UserRepository {
  final UserService _userService;

  UserRepository({UserService? userService})
      : _userService = userService ?? UserService();

  Future<UserResponse> getUsers({required PaginationParams params}) async {
    try {
      final response = await _userService.getUsers(params: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
