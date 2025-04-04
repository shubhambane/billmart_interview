class PaginationParams {
  final int page;
  final int perPage;

  const PaginationParams({
    this.page = 1,
    this.perPage = 6,
  });

  PaginationParams copyWith({
    int? page,
    int? perPage,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
    };
  }
}
