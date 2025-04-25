import 'package:flutter/material.dart';
import 'package:budget_tracker/services/firestore_service.dart';
import 'package:budget_tracker/widgets/pie_chart_widget.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:intl/intl.dart';

class SummaryPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  Widget _buildGradientText(
    String text, {
    double fontSize = 24,
    bool isActive = true,
  }) {
    return ShaderMask(
      shaderCallback:
          (bounds) => LinearGradient(
            colors:
                isActive
                    ? [
                      const Color.fromARGB(255, 32, 33, 33),
                      const Color.fromARGB(255, 56, 57, 57),
                    ]
                    : [
                      const Color.fromARGB(255, 128, 127, 127),
                      const Color.fromARGB(255, 177, 176, 176),
                    ],
          ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                    : [Colors.white, const Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGradientText(
                      'Monthly Summary (${DateFormat.yMMM().format(now)})',
                      fontSize: 22,
                      isActive: true,
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<Map<String, dynamic>>(
                      stream: _firestoreService.getSummary(
                        startOfMonth,
                        endOfMonth,
                      ),
                      builder: (context, summarySnapshot) {
                        if (summarySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00E7FF),
                            ),
                          );
                        }
                        if (summarySnapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading summary: ${summarySnapshot.error}',
                              style: TextStyle(
                                color: isDark ? Colors.red[300] : Colors.red,
                                fontFamily: 'Roboto',
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        final summary =
                            summarySnapshot.data ??
                            {
                              'totalIncome': 0.0,
                              'totalExpenses': 0.0,
                              'categoryBreakdown': <String, double>{},
                            };

                        final totalIncome = summary['totalIncome'] as double;
                        final totalExpenses =
                            summary['totalExpenses'] as double;
                        final categoryBreakdown =
                            summary['categoryBreakdown'] as Map<String, double>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryCard(
                              isDark: isDark,
                              totalIncome: totalIncome,
                              totalExpenses: totalExpenses,
                              isTablet: isTablet,
                            ),
                            const SizedBox(height: 12),
                            _buildGradientText(
                              'Expense Breakdown by Category',
                              fontSize: 16,
                              isActive: true,
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight * 0.3,
                                minHeight: 120,
                              ),
                              child: PieChartWidget(
                                categoryBreakdown: categoryBreakdown,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildGradientText(
                              'Budget Overview',
                              fontSize: 16,
                              isActive: true,
                            ),
                            const SizedBox(height: 8),
                            _buildBudgetOverview(
                              categoryBreakdown: categoryBreakdown,
                              isDark: isDark,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required bool isDark,
    required double totalIncome,
    required double totalExpenses,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6, // Smaller shadow
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Income',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalIncome.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expenses',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalExpenses.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value:
                totalIncome > 0
                    ? (totalExpenses / totalIncome).clamp(0.0, 1.0)
                    : 0.0,
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
            color:
                totalExpenses > totalIncome
                    ? Colors.red[700]
                    : Colors.green[700],
            minHeight: 5,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            totalIncome > 0
                ? 'Expense Ratio: ${(totalExpenses / totalIncome * 100).toStringAsFixed(1)}%'
                : 'No income recorded',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview({
    required Map<String, double> categoryBreakdown,
    required bool isDark,
  }) {
    return StreamBuilder<List<Budget>>(
      stream: _firestoreService.getBudgets(),
      builder: (context, budgetSnapshot) {
        if (budgetSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00E7FF)),
          );
        }
        if (budgetSnapshot.hasError) {
          return Center(
            child: Text(
              'Error loading budgets: ${budgetSnapshot.error}',
              style: TextStyle(
                color: isDark ? Colors.red[300] : Colors.red,
                fontFamily: 'Roboto',
                fontSize: 14,
              ),
            ),
          );
        }
        final budgets = budgetSnapshot.data ?? [];
        if (categoryBreakdown.isEmpty) {
          return const Center(
            child: Text(
              'No expenses recorded',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 14),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categoryBreakdown.length,
          separatorBuilder: (context, index) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final category = categoryBreakdown.keys.elementAt(index);
            final spent = categoryBreakdown[category]!;
            final budget = budgets.firstWhere(
              (b) => b.category == category,
              orElse:
                  () => Budget(
                    id: '',
                    category: category,
                    limit: double.infinity,
                  ),
            );
            final isOverBudget =
                spent > budget.limit && budget.limit != double.infinity;

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        isOverBudget
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        color: isOverBudget ? Colors.red : Colors.green,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Spent \$${spent.toStringAsFixed(2)} / Budget \$${budget.limit == double.infinity ? 'Not Set' : budget.limit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11,
                      color:
                          isOverBudget
                              ? Colors.red[600]
                              : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value:
                        budget.limit == double.infinity
                            ? 0
                            : (spent / budget.limit).clamp(0.0, 1.0),
                    backgroundColor:
                        isDark ? Colors.grey[700] : Colors.grey[200],
                    color: isOverBudget ? Colors.red[700] : Colors.blue[700],
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
