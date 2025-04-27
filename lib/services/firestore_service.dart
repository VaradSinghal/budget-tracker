import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as app;
import '../models/budget.dart';

class FirestoreService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? _cachedUserId;
  static CollectionReference<Map<String, dynamic>>?
  _cachedTransactionsCollection;
  static CollectionReference<Map<String, dynamic>>? _cachedCategoriesCollection;
  static CollectionReference<Map<String, dynamic>>? _cachedBudgetsCollection;


  String get _userId {
    if (_cachedUserId != null) return _cachedUserId!;
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    _cachedUserId = user.uid;
    return _cachedUserId!;
  }

  CollectionReference<Map<String, dynamic>> _getTransactionsCollection() {
    return _cachedTransactionsCollection ??= _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions');
  }

  CollectionReference<Map<String, dynamic>> _getCategoriesCollection() {
    return _cachedCategoriesCollection ??= _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories');
  }

  CollectionReference<Map<String, dynamic>> _getBudgetsCollection() {
    return _cachedBudgetsCollection ??= _firestore
        .collection('users')
        .doc(_userId)
        .collection('budgets');
  }


  final WriteBatch _batch = _firestore.batch();

  Future<void> addTransaction(app.Transaction transaction) async {
    _batch.set(_getTransactionsCollection().doc(), transaction.toMap());
    await _batch.commit();
  }

  Stream<List<app.Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int limit = 50,
  }) {
    Query query = _getTransactionsCollection()
        .orderBy('date', descending: true)
        .limit(limit);

  
    if (startDate != null && endDate != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: _startOfDay(startDate))
          .where('date', isLessThanOrEqualTo: _endOfDay(endDate));
    }

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            return await Future.wait(
              snapshot.docs.map((doc) async {
                try {
                  return app.Transaction.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                } catch (e) {
                  print('Error parsing transaction ${doc.id}: $e');
                  return null;
                }
              }),
            ).then(
              (transactions) =>
                  transactions.whereType<app.Transaction>().toList(),
            );
          } catch (e) {
            print('Error processing transaction stream: $e');
            return <app.Transaction>[];
          }
        })
        .handleError((error) {
          print('Error fetching transactions: $error');
          return <app.Transaction>[];
        });
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);
  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  Stream<Map<String, dynamic>> getSummary(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _getTransactionsCollection()
        .where('date', isGreaterThanOrEqualTo: _startOfDay(startDate))
        .where('date', isLessThanOrEqualTo: _endOfDay(endDate))
        .snapshots()
        .asyncMap((snapshot) {
          final completer = Completer<Map<String, dynamic>>();
          double totalIncome = 0;
          double totalExpenses = 0;
          final categoryBreakdown = <String, double>{};

    
          const chunkSize = 50;
          final totalDocs = snapshot.docs.length;
          int processed = 0;

          void processChunk(int startIndex) {
            final endIndex = (startIndex + chunkSize).clamp(0, totalDocs);

            for (int i = startIndex; i < endIndex; i++) {
              final doc = snapshot.docs[i];
              final data = doc.data();
              final amount = (data['amount'] as num).toDouble();
              final type = data['type'] as String;
              final category = data['category'] as String?;

              if (type == 'income') {
                totalIncome += amount;
              } else {
                totalExpenses += amount;
                if (category != null) {
                  categoryBreakdown[category] =
                      (categoryBreakdown[category] ?? 0) + amount;
                }
              }
            }

            processed = endIndex;

            if (processed < totalDocs) {
         
              Future.microtask(() => processChunk(processed));
            } else {
              completer.complete({
                'totalIncome': totalIncome,
                'totalExpenses': totalExpenses,
                'categoryBreakdown': categoryBreakdown,
              });
            }
          }

      
          processChunk(0);

          return completer.future;
        });
  }

  static List<String>? _cachedCategories;
  static DateTime? _lastCategoryFetchTime;

  Stream<List<String>> getCategories() {
    final now = DateTime.now();
    if (_cachedCategories != null &&
        _lastCategoryFetchTime != null &&
        now.difference(_lastCategoryFetchTime!) < const Duration(minutes: 5)) {
      return Stream.value(_cachedCategories!);
    }

    return _getCategoriesCollection().snapshots().asyncMap((snapshot) {
      final customCategories =
          snapshot.docs
              .map((doc) => doc.data()['name'] as String)
              .where((name) => name.isNotEmpty)
              .toList();

      const defaultCategories = [
        'Groceries',
        'Bills',
        'Entertainment',
        'Transport',
        'Health',
        'Education',
        'Shopping',
        'Dining',
        'Travel',
        'Other',
      ];

      _cachedCategories =
          [...customCategories, ...defaultCategories].toSet().toList()..sort();

      _lastCategoryFetchTime = DateTime.now();

      return _cachedCategories!;
    });
  }

  Future<void> addCategory(String category) async {
    if (category.isEmpty) return;
    await _getCategoriesCollection().add({'name': category.trim()});
    _cachedCategories = null; // Invalidate cache
  }

  Future<void> deleteCategory(String category) async {
    final query =
        await _getCategoriesCollection()
            .where('name', isEqualTo: category)
            .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _cachedCategories = null; // Invalidate cache
  }

  // Optimized budget operations
  Future<void> addBudget(Budget budget) async {
    await _getBudgetsCollection().add(budget.toMap());
  }

  Future<void> updateBudget(Budget budget) async {
    if (budget.id.isEmpty) return;
    await _getBudgetsCollection().doc(budget.id).update(budget.toMap());
  }

  Future<void> deleteBudget(String budgetId) async {
    if (budgetId.isEmpty) return;
    await _getBudgetsCollection().doc(budgetId).delete();
  }

  Stream<List<Budget>> getBudgets() {
    return _getBudgetsCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          return await Future.wait(
            snapshot.docs.map((doc) async {
              try {
                return Budget.fromMap(doc.data(), doc.id);
              } catch (e) {
                print('Error parsing budget ${doc.id}: $e');
                return null;
              }
            }),
          ).then((budgets) => budgets.whereType<Budget>().toList());
        });
  }

  // Optimized monthly trends calculation
  Stream<Map<String, Map<String, double>>> getMonthlyTrends(int months) {
    final startDate = DateTime(
      DateTime.now().year,
      DateTime.now().month - months + 1,
      1,
    );

    return _getTransactionsCollection()
        .where('date', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .asyncMap((snapshot) {
          final completer = Completer<Map<String, Map<String, double>>>();
          final trends = <String, Map<String, double>>{};

          final chunkSize = 50;
          final totalDocs = snapshot.docs.length;
          int processed = 0;

          void processChunk(int startIndex) {
            final endIndex = (startIndex + chunkSize).clamp(0, totalDocs);

            for (int i = startIndex; i < endIndex; i++) {
              final doc = snapshot.docs[i];
              final data = doc.data();
              final date = (data['date'] as Timestamp).toDate();
              final amount = (data['amount'] as num).toDouble();
              final type = data['type'] as String;
              final monthKey =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}';

              trends.putIfAbsent(
                monthKey,
                () => {'income': 0.0, 'expenses': 0.0},
              );

              if (type == 'income') {
                trends[monthKey]!['income'] =
                    trends[monthKey]!['income']! + amount;
              } else {
                trends[monthKey]!['expenses'] =
                    trends[monthKey]!['expenses']! + amount;
              }
            }

            processed = endIndex;

            if (processed < totalDocs) {
              Future.microtask(() => processChunk(processed));
            } else {
              completer.complete(trends);
            }
          }

          processChunk(0);
          return completer.future;
        });
  }
}