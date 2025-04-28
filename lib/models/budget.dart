import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String category;
  final double limit;
  final DateTime? createdAt;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(), 
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map, String id) {
    return Budget(
      id: id,
      category: map['category'] as String,
      limit: (map['limit'] as num).toDouble(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, category: $category, limit: $limit, createdAt: $createdAt)';
  }
}