import 'package:flutter/material.dart';
import 'package:budget_tracker/services/firestore_service.dart';
import 'package:budget_tracker/widgets/pie_chart_widget.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:intl/intl.dart';

class SummaryPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary (${DateFormat.yMMM().format(now)})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            StreamBuilder<Map<String, dynamic>>(
              stream: _firestoreService.getSummary(startOfMonth, endOfMonth),
              builder: (context, summarySnapshot) {
                if (summarySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (summarySnapshot.hasError) {
                  return const Center(child: Text('Error loading summary'));
                }

                final summary = summarySnapshot.data ?? {
                  'totalIncome': 0.0,
                  'totalExpenses': 0.0,
                  'categoryBreakdown': <String, double>{},
                };

                final totalIncome = summary['totalIncome'] as double;
                final totalExpenses = summary['totalExpenses'] as double;
                final categoryBreakdown =
                    summary['categoryBreakdown'] as Map<String, double>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Income: \$${totalIncome.toStringAsFixed(2)}'),
                    Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
                    const SizedBox(height: 16),
                    Text(
                      'Expense Breakdown:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(
                      height: 200,
                      child: PieChartWidget(categoryBreakdown: categoryBreakdown),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Budget Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    StreamBuilder<List<Budget>>(
                      stream: _firestoreService.getBudgets(),
                      builder: (context, budgetSnapshot) {
                        if (!budgetSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final budgets = budgetSnapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryBreakdown.length,
                          itemBuilder: (context, index) {
                            final category = categoryBreakdown.keys.elementAt(index);
                            final spent = categoryBreakdown[category]!;
                            final budget = budgets.firstWhere(
                              (b) => b.category == category,
                              orElse: () => Budget(id: '', category: category, limit: double.infinity),
                            );
                            final isOverBudget = spent > budget.limit;
                            return ListTile(
                              title: Text(category),
                              subtitle: Text(
                                'Spent: \$${spent.toStringAsFixed(2)} / Budget: \$${budget.limit.toStringAsFixed(2)}',
                              ),
                              trailing: isOverBudget
                                  ? const Icon(Icons.warning, color: Colors.red)
                                  : const Icon(Icons.check, color: Colors.green),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}