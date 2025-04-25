import 'package:flutter/material.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/firestore_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;

  void _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text(
                    _startDate == null
                        ? 'Select Date Range'
                        : '${DateFormat.yMMMd().format(_startDate!)} - ${DateFormat.yMMMd().format(_endDate!)}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StreamBuilder<List<String>>(
                stream: _firestoreService.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButton<String>(
                    hint: const Text('Category'),
                    value: _selectedCategory,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...snapshot.data!
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) => setState(() => _selectedCategory = value),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearFilters,
                tooltip: 'Clear Filters',
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
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading transactions'));
              }

              final transactions = snapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    title: Text(transaction.description),
                    subtitle: Text(
                      '${transaction.type[0].toUpperCase()}${transaction.type.substring(1)}'
                      '${transaction.category != null ? ' - ${transaction.category}' : ''} - '
                      '${DateFormat.yMMMd().format(transaction.date)}',
                    ),
                    trailing: Text(
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction.type == 'income' ? Colors.green : Colors.red,
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
  }
}