import 'package:flutter/material.dart';
import 'package:budget_tracker/services/firestore_service.dart';
import 'package:budget_tracker/models/budget.dart';

class BudgetSettingsPage extends StatefulWidget {
  const BudgetSettingsPage({Key? key}) : super(key: key);

  @override
  _BudgetSettingsPageState createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends State<BudgetSettingsPage>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final _budgetLimitController = TextEditingController();
  late AnimationController _fadeController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _budgetLimitController.dispose();
    super.dispose();
  }

  void _addOrUpdateBudget(List<Budget> budgets) async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      try {
        final existingBudget = budgets.firstWhere(
          (budget) => budget.category == _selectedCategory,
          orElse: () => Budget(id: '', category: _selectedCategory!, limit: 0),
        );
        final budget = Budget(
          id: existingBudget.id.isEmpty ? '' : existingBudget.id,
          category: _selectedCategory!,
          limit: double.parse(_budgetLimitController.text.trim()),
        );
        print('Saving budget: $budget'); // Debug log
        if (existingBudget.id.isEmpty) {
          await _firestoreService.addBudget(budget);
        } else {
          await _firestoreService.updateBudget(budget);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Budget saved successfully'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500)); // Add delay
        _formKey.currentState!.reset();
        _budgetLimitController.clear();
        setState(() {
          _selectedCategory = null;
          _isSaving = false;
        });
      } catch (e) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save budget: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _deleteBudget(String budgetId) async {
    try {
      await _firestoreService.deleteBudget(budgetId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Budget deleted successfully'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete budget: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildGradientText(
    String text, {
    double fontSize = 24,
    bool isActive = true,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: isActive
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildGradientText(
          'Budget Settings',
          fontSize: 26,
          isActive: true,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                : [Colors.white, const Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBudgetForm(isDark, isTablet),
                      const SizedBox(height: 24),
                      _buildGradientText(
                        'Current Budgets',
                        fontSize: 20,
                        isActive: true,
                      ),
                      const SizedBox(height: 16),
                      _buildBudgetList(isDark),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetForm(bool isDark, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: StreamBuilder<List<String>>(
        stream: _firestoreService.getCategories(),
        builder: (context, categorySnapshot) {
          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E7FF)),
            );
          }
          if (categorySnapshot.hasError) {
            return Center(
              child: Text(
                'Error loading categories: ${categorySnapshot.error}',
                style: TextStyle(
                  color: isDark ? Colors.red[300] : Colors.red,
                  fontFamily: 'Roboto',
                ),
              ),
            );
          }
          if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No categories available',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
            );
          }
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
                    ),
                  ),
                );
              }
              final budgets = budgetSnapshot.data ?? [];
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: categorySnapshot.data!
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        _selectedCategory = value;
                        final existingBudget = budgets.firstWhere(
                          (budget) => budget.category == value,
                          orElse: () =>
                              Budget(id: '', category: value!, limit: 0),
                        );
                        _budgetLimitController.text =
                            existingBudget.limit == 0
                                ? ''
                                : existingBudget.limit.toString();
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetLimitController,
                      decoration: InputDecoration(
                        labelText: 'Budget Limit',
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a budget limit';
                        }
                        if (double.tryParse(value.trim()) == null ||
                            double.parse(value.trim()) <= 0) {
                          return 'Enter a valid positive amount';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSaving ? null : () => _addOrUpdateBudget(budgets),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 1, 19, 21),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 16,
                          vertical: 12,
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Budget',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBudgetList(bool isDark) {
    return StreamBuilder<List<Budget>>(
      stream: _firestoreService.getBudgets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00E7FF)),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading budgets: ${snapshot.error}',
              style: TextStyle(
                color: isDark ? Colors.red[300] : Colors.red,
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No budgets set',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
            ),
          );
        }
        final budgets = snapshot.data!;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return FadeTransition(
                opacity: _fadeController,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      budget.category,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Limit: \$${budget.limit.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: isDark ? Colors.red[300] : Colors.red[700],
                      ),
                      onPressed: () => _deleteBudget(budget.id),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}