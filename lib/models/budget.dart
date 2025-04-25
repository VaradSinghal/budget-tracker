class Budget {
  final String id;
  final String category;
  final double limit;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
  });

  factory Budget.fromMap(Map<String, dynamic> map, String id) {
    return Budget(
      id: id,
      category: map['category'],
      limit: map['limit'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
    };
  }
}