import 'package:flutter/material.dart';
import 'package:budget_tracker/services/firestore_service.dart';
import 'package:budget_tracker/models/budget.dart';

class BudgetSettingsPage extends StatefulWidget {
  @override
  _BudgetSettingsPageState createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends State<BudgetSettingsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String _budgetLimit = '';

  void _addOrUpdateBudget(List<Budget> budgets) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final existingBudget = budgets.firstWhere(
        (budget) => budget.category == _selectedCategory,
        orElse: () => Budget(id: '', category: _selectedCategory!, limit: 0),
      );
      final budget = Budget(
        id: existingBudget.id.isEmpty ? '' : existingBudget.id,
        category: _selectedCategory!,
        limit: double.parse(_budgetLimit),
      );
      if (existingBudget.id.isEmpty) {
        await _firestoreService.addBudget(budget);
      } else {
        await _firestoreService.updateBudget(budget);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget saved')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _selectedCategory = null;
        _budgetLimit = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<List<String>>(
              stream: _firestoreService.getCategories(),
              builder: (context, categorySnapshot) {
                if (!categorySnapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return StreamBuilder<List<Budget>>(
                  stream: _firestoreService.getBudgets(),
                  builder: (context, budgetSnapshot) {
                    if (!budgetSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final budgets = budgetSnapshot.data!;
                    return Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            items: categorySnapshot.data!
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                                final existingBudget = budgets.firstWhere(
                                  (budget) => budget.category == value,
                                  orElse: () =>
                                      Budget(id: '', category: value!, limit: 0),
                                );
                                _budgetLimit = existingBudget.limit == 0
                                    ? ''
                                    : existingBudget.limit.toString();
                              });
                            },
                            decoration: const InputDecoration(labelText: 'Category'),
                            validator: (value) =>
                                value == null ? 'Select a category' : null,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Budget Limit'),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty || double.tryParse(value) == null
                                    ? 'Enter a valid amount'
                                    : null,
                            onSaved: (value) => _budgetLimit = value!,
                            initialValue: _budgetLimit,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _addOrUpdateBudget(budgets),
                            child: const Text('Save Budget'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Budget>>(
                stream: _firestoreService.getBudgets(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final budgets = snapshot.data!;
                  return ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      return ListTile(
                        title: Text(budget.category),
                        subtitle: Text('Limit: \$${budget.limit.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _firestoreService.deleteBudget(budget.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Budget deleted')),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}