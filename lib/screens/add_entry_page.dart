import 'package:flutter/material.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/firestore_service.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({Key? key}) : super(key: key);

  @override
  _AddEntryPageState createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'expense';
  String _description = '';
  String _amount = '';
  String? _category;
  bool _isSubmitting = false;
  final FirestoreService _firestoreService = FirestoreService();

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

  void _submitEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });
      try {
        final transaction = Transaction(
          id: '',
          type: _type,
          description: _description,
          amount: double.parse(_amount),
          category: _type == 'expense' ? _category : null,
          date: DateTime.now(),
        );
        await _firestoreService.addTransaction(transaction);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Entry added successfully',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 14),
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _category = null;
          _type = 'expense';
          _amount = '';
          _description = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error adding entry: $e',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      'Add Transaction',
                      fontSize: 22,
                      isActive: true,
                    ),
                    const SizedBox(height: 12),
                    Container(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _type,
                              items: [
                                DropdownMenuItem(
                                  value: 'income',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_circle_up,
                                        color: Colors.green[700],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Income',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color:
                                              isDark
                                                  ? Colors.grey[200]
                                                  : Colors.grey[900],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'expense',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_circle_down,
                                        color: Colors.red[700],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Expense',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color:
                                              isDark
                                                  ? Colors.grey[200]
                                                  : Colors.grey[900],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged:
                                  (value) => setState(() {
                                    _type = value!;
                                    _category = null;
                                  }),
                              decoration: InputDecoration(
                                labelText: 'Transaction Type',
                                labelStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.swap_horiz,
                                  color:
                                      _type == 'income'
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                  size: 20,
                                ),
                                filled: true,
                                fillColor:
                                    isDark
                                        ? Colors.grey[900]
                                        : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.blue[700]!,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
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
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.description,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.blue[700]!,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.red[700]!,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.red[700]!,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Please enter a description'
                                          : null,
                              onSaved: (value) => _description = value!,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                labelStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.blue[700]!,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.red[700]!,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.red[700]!,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                if (double.tryParse(value) == null ||
                                    double.parse(value) <= 0) {
                                  return 'Enter a valid positive amount';
                                }
                                return null;
                              },
                              onSaved: (value) => _amount = value!,
                            ),
                            if (_type == 'expense') ...[
                              const SizedBox(height: 12),
                              StreamBuilder<List<String>>(
                                stream: _firestoreService.getCategories(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF00E7FF),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return Text(
                                      'Error loading categories: ${snapshot.error}',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 14,
                                        color: Colors.red[700],
                                      ),
                                    );
                                  }
                                  final categories = snapshot.data ?? [];
                                  if (categories.isEmpty) {
                                    return const Text(
                                      'No categories available',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                  return DropdownButtonFormField<String>(
                                    value: _category,
                                    items:
                                        categories
                                            .map(
                                              (category) => DropdownMenuItem(
                                                value: category,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.category,
                                                      color: Colors.blue[700],
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      category.length > 15
                                                          ? '${category.substring(0, 12)}...'
                                                          : category,
                                                      style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 14,
                                                        color:
                                                            isDark
                                                                ? Colors
                                                                    .grey[200]
                                                                : Colors
                                                                    .grey[900],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        (value) =>
                                            setState(() => _category = value),
                                    decoration: InputDecoration(
                                      labelText: 'Category',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 14,
                                        color:
                                            isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[700],
                                      ),
                                      prefixIcon: Icon(
                                        Icons.category,
                                        color:
                                            isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[700],
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor:
                                          isDark
                                              ? Colors.grey[900]
                                              : Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color:
                                              isDark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                          width: 0.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.blue[700]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.red[700]!,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.red[700]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                    ),
                                    validator:
                                        (value) =>
                                            value == null
                                                ? 'Please select a category'
                                                : null,
                                    dropdownColor:
                                        isDark
                                            ? Colors.grey[900]
                                            : Colors.white,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color:
                                          isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[700],
                                    ),
                                    menuMaxHeight: 200,
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitEntry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child:
                                  _isSubmitting
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'Add Transaction',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
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
}
