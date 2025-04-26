import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as app;
import '../models/budget.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getTransactionsCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  CollectionReference<Map<String, dynamic>> _getCategoriesCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories');
  }

  CollectionReference<Map<String, dynamic>> _getBudgetsCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('budgets');
  }

  Future<void> addTransaction(app.Transaction transaction) async {
    await _getTransactionsCollection().add(transaction.toMap());
  }

  Stream<List<app.Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) {
    var query = _getTransactionsCollection().orderBy('date', descending: true);

    if (startDate != null && endDate != null) {
      final adjustedStartDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        0,
        0,
        0,
      );
      final adjustedEndDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
        999,
      );

      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(adjustedStartDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(adjustedEndDate));
    }

    if (category != null) {
      // Only apply category filter if the category is not null
      query = query.where('category', isEqualTo: category, isNull: false);
    }

    return query.snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => app.Transaction.fromMap(doc.data(), doc.id))
            .whereType<app.Transaction>() // Filter out null results
            .toList();
      } catch (e) {
        print('Error mapping transaction data: $e');
        return [];
      }
    });
  }

  Stream<Map<String, dynamic>> getSummary(DateTime startDate, DateTime endDate) {
    final adjustedStartDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final adjustedEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    return _getTransactionsCollection()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(adjustedStartDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(adjustedEndDate))
        .snapshots()
        .map((snapshot) {
      double totalIncome = 0;
      double totalExpenses = 0;
      Map<String, double> categoryBreakdown = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num).toDouble();
        final type = data['type'] as String;
        final category = data['category'] as String?;

        if (type == 'income') {
          totalIncome += amount;
        } else {
          totalExpenses += amount;
          if (category != null) {
            categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + amount;
          }
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'categoryBreakdown': categoryBreakdown,
      };
    });
  }

  Stream<List<String>> getCategories() {
    return _getCategoriesCollection().snapshots().map((snapshot) {
      final categories = snapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
      return {
        ...categories,
        'Groceries',
        'Bills',
        'Entertainment',
        'Transport',
        'Health',
        'Education',
      }.toList();
    });
  }

  Future<void> addCategory(String category) async {
    await _getCategoriesCollection().add({'name': category});
  }

  Future<void> deleteCategory(String category) async {
    final snapshot = await _getCategoriesCollection()
        .where('name', isEqualTo: category)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> addBudget(Budget budget) async {
    await _getBudgetsCollection().add(budget.toMap());
  }

  Future<void> updateBudget(Budget budget) async {
    await _getBudgetsCollection().doc(budget.id).set(budget.toMap());
  }

  Future<void> deleteBudget(String budgetId) async {
    await _getBudgetsCollection().doc(budgetId).delete();
  }

  Stream<List<Budget>> getBudgets() {
    return _getBudgetsCollection().snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Budget.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<Map<String, Map<String, double>>> getMonthlyTrends(int months) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months + 1, 1);
    return _getTransactionsCollection()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .snapshots()
        .map((snapshot) {
      Map<String, Map<String, double>> trends = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final amount = (data['amount'] as num).toDouble();
        final type = data['type'] as String;
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

        trends[monthKey] ??= {'income': 0.0, 'expenses': 0.0};
        if (type == 'income') {
          trends[monthKey]!['income'] = trends[monthKey]!['income']! + amount;
        } else {
          trends[monthKey]!['expenses'] = trends[monthKey]!['expenses']! + amount;
        }
      }

      return trends;
    });
  }
}