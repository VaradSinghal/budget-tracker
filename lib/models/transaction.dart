class Transaction {
  final String id;
  final String type; // 'income' or 'expense'
  final String description;
  final double amount;
  final String? category;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    this.category,
    required this.date,
  });

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      type: map['type'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      date: (map['date']).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }
}