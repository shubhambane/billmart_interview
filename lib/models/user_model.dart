class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
    );
  }
}

class Support {
  final String url;
  final String text;

  Support({
    required this.url,
    required this.text,
  });

  factory Support.fromJson(Map<String, dynamic> json) {
    return Support(
      url: json['url'],
      text: json['text'],
    );
  }
}

class UserDetailResponse {
  final User data;
  final Support support;

  UserDetailResponse({
    required this.data,
    required this.support,
  });

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailResponse(
      data: User.fromJson(json['data']),
      support: Support.fromJson(json['support']),
    );
  }
}

class UserResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<User> data;

  UserResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      data: (json['data'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList(),
    );
  }
}
