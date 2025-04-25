import 'package:flutter/material.dart';
import 'package:budget_tracker/services/firestore_service.dart';

class ManageCategoriesPage extends StatefulWidget {
  @override
  _ManageCategoriesPageState createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  String _newCategory = '';

  void _addCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _firestoreService.addCategory(_newCategory);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _newCategory = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'New Category'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a category name' : null,
                      onSaved: (value) => _newCategory = value!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addCategory,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: _firestoreService.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final customCategories = snapshot.data!
                      .where((category) => ![
                            'Groceries',
                            'Bills',
                            'Entertainment',
                            'Transport',
                            'Health',
                            'Education'
                          ].contains(category))
                      .toList();
                  return ListView.builder(
                    itemCount: customCategories.length,
                    itemBuilder: (context, index) {
                      final category = customCategories[index];
                      return ListTile(
                        title: Text(category),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _firestoreService.deleteCategory(category);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Category deleted')),
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