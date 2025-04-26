import 'package:flutter/material.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/firestore_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;

  Widget _buildGradientText(
    String text, {
    double fontSize = 22,
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

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]!
                      : Colors.grey[700]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 12,
                    vertical: 12,
                  ),
                  child: _buildGradientText(
                    'Transaction History',
                    fontSize: 22,
                    isActive: true,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          _startDate == null
                              ? 'Select Date Range'
                              : '${DateFormat.yMMMd().format(_startDate!)} - ${DateFormat.yMMMd().format(_endDate!)}',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder<List<String>>(
                        stream: _firestoreService.getCategories(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(
                              color: Color(0xFF00E7FF),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                color: Colors.red[700],
                              ),
                            );
                          }
                          final categories = snapshot.data ?? [];
                          return Container(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 200 : 150,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.grey[900] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                width: 0.5,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                hint: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'Category',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      color:
                                          isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'All Categories',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color:
                                              isDark
                                                  ? Colors.grey[200]
                                                  : Colors.grey[900],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...categories.map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.category,
                                              color: Colors.blue[700],
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                category.length > 15
                                                    ? '${category.substring(0, 12)}...'
                                                    : category,
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 14,
                                                  color:
                                                      isDark
                                                          ? Colors.grey[200]
                                                          : Colors.grey[900],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                                isExpanded: true,
                                dropdownColor:
                                    isDark ? Colors.grey[900] : Colors.white,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                ),
                                menuMaxHeight: 200,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          size: 24,
                        ),
                        onPressed: _clearFilters,
                        tooltip: 'Clear Filters',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.grey[900] : Colors.grey[100],
                          padding: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {}); // Trigger rebuild to refresh stream
                        },
                        tooltip: 'Refresh Transactions',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.grey[900] : Colors.grey[100],
                          padding: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Transaction>>(
                    stream: _firestoreService.getTransactions(
                      startDate: _startDate,
                      endDate: _endDate,
                      category: _selectedCategory,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00E7FF),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        print('Error loading transactions: ${snapshot.error}');
                        return Center(
                          child: Text(
                            'Error loading transactions: ${snapshot.error}',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.red[700],
                            ),
                          ),
                        );
                      }

                      final transactions = snapshot.data ?? [];

                      if (transactions.isEmpty) {
                        return Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 12,
                          vertical: 8,
                        ),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return GestureDetector(
                            onTap: () {
                              // Placeholder for future transaction details modal
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tapped: ${transaction.description}',
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue[700],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black12 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          transaction.type == 'income'
                                              ? Colors.green[700]!.withOpacity(
                                                0.1,
                                              )
                                              : Colors.red[700]!.withOpacity(
                                                0.1,
                                              ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      transaction.type == 'income'
                                          ? Icons.arrow_circle_up
                                          : Icons.arrow_circle_down,
                                      color:
                                          transaction.type == 'income'
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transaction.description,
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isDark
                                                    ? Colors.grey[200]
                                                    : Colors.grey[900],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${transaction.type[0].toUpperCase()}${transaction.type.substring(1)}'
                                          '${transaction.category != null ? ' - ${transaction.category}' : ''} - '
                                          '${DateFormat.yMMMd().format(transaction.date)}',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 12,
                                            color:
                                                isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[700],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '\$${transaction.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          transaction.type == 'income'
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
