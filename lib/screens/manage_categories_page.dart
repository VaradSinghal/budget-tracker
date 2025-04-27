import 'package:flutter/material.dart';
import 'package:budget_tracker/services/firestore_service.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({Key? key}) : super(key: key);

  @override
  _ManageCategoriesPageState createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  String _newCategory = '';
  late AnimationController _fadeController;

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
    super.dispose();
  }

  void _addCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _firestoreService.addCategory(_newCategory.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Category added successfully'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _newCategory = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add category: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _deleteCategory(String category) async {
    try {
      await _firestoreService.deleteCategory(category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Category deleted successfully'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete category: $e'),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildGradientText(
          'Manage Categories',
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
                    _buildAddCategoryForm(isDark, isTablet),
                    const SizedBox(height: 24),
                    _buildGradientText(
                      'Custom Categories',
                      fontSize: 20,
                      isActive: true,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildCategoryList(isDark),
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

  Widget _buildAddCategoryForm(bool isDark, bool isTablet) {
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
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'New Category',
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a category name';
                  }
                  return null;
                },
                onSaved: (value) => _newCategory = value!,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addCategory,
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
              child: const Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(bool isDark) {
    return StreamBuilder<List<String>>(
      stream: _firestoreService.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00E7FF)));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading categories: ${snapshot.error}',
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
              'No custom categories available',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
            ),
          );
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    category,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: isDark ? Colors.red[300] : Colors.red[700],
                    ),
                    onPressed: () => _deleteCategory(category),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}