import 'package:flutter/material.dart';
import 'package:budget_tracker/screens/add_entry_page.dart';
import 'package:budget_tracker/screens/history_page.dart';
import 'package:budget_tracker/screens/summary_page.dart';
import 'package:budget_tracker/screens/manage_categories_page.dart';
import 'package:budget_tracker/screens/budget_settings_page.dart';
import 'package:budget_tracker/services/auth_service.dart';
import 'package:budget_tracker/widgets/trend_chart_widget.dart';
import 'package:budget_tracker/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final List<Widget> _pages = [SummaryPage(), const AddEntryPage(), const HistoryPage()];

  late AnimationController _chartTitleController;
  late Animation<double> _chartTitleBounceAnimation;
  late AnimationController _drawerHeaderController;
  late Animation<double> _drawerHeaderScaleAnimation;

  @override
  void initState() {
    super.initState();

    _chartTitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chartTitleBounceAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _chartTitleController, curve: Curves.elasticOut),
    );
    _chartTitleController.forward();

    _drawerHeaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _drawerHeaderScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _drawerHeaderController, curve: Curves.easeOut),
    );
    _drawerHeaderController.forward();
  }

  @override
  void dispose() {
    _chartTitleController.dispose();
    _drawerHeaderController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _chartTitleController.forward(from: 0);
      }
    });
  }

  void _logout() async {
    await _authService.logout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Color.fromARGB(255, 27, 28, 28),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildGradientText(
    String text, {
    double fontSize = 24,
    bool isActive = false,
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
        title: buildGradientText(
          'Budget Tracker',
          fontSize: 26,
          isActive: true,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: _selectedIndex == 0
                  ? const Color.fromARGB(255, 1, 16, 18)
                  : Colors.grey,
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _buildDrawer(isDark),
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
                  horizontal: isTablet ? 24 : 12,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    if (_selectedIndex == 0) ...[
                      _buildTrendChartCard(context, isDark, isTablet, constraints.maxWidth),
                      const SizedBox(height: 8),
                    ],
                    Expanded(child: _pages[_selectedIndex]),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2A2F30), const Color(0xFF1E1E1E)]
                : [Colors.white, const Color(0xFFE0E0E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(isDark),
            _buildDrawerTile(
              title: 'Manage Categories',
              icon: Icons.category,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageCategoriesPage(),
                  ),
                );
              },
            ),
            _buildDrawerTile(
              title: 'Budget Settings',
              icon: Icons.account_balance_wallet,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BudgetSettingsPage()),
                );
              },
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
            ),
            _buildDrawerTile(
              title: 'Logout',
              icon: Icons.logout,
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2A2F30), const Color(0xFF1E1E1E)]
              : [const Color(0xFFE3F2FD), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedBuilder(
        animation: _drawerHeaderController,
        builder: (context, child) {
          return Transform.scale(
            scale: _drawerHeaderScaleAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 50,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                buildGradientText(
                  'Budget Tracker',
                  fontSize: 24,
                  isActive: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[700],
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[700],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return BottomNavigationBar(
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      selectedItemColor: const Color.fromARGB(255, 1, 19, 21),
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[700],
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto'),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.pie_chart,
            color: _selectedIndex == 0
                ? const Color.fromARGB(255, 2, 19, 21)
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
          label: 'Summary',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add,
            color: _selectedIndex == 1
                ? const Color.fromARGB(255, 0, 19, 21)
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
          label: 'Add Entry',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.history,
            color: _selectedIndex == 2
                ? const Color.fromARGB(255, 1, 21, 23)
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
          label: 'History',
        ),
      ],
    );
  }

  Widget _buildTrendChartCard(
    BuildContext context,
    bool isDark,
    bool isTablet,
    double maxWidth,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _chartTitleController,
            builder: (context, child) {
              return Transform.scale(
                scale: _chartTitleBounceAnimation.value,
                child: buildGradientText(
                  'Income vs Expenses Trend',
                  fontSize: 18,
                  isActive: true,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<Map<String, Map<String, double>>>(
            stream: _firestoreService.getMonthlyTrends(6),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00E7FF)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading trends',
                    style: TextStyle(
                      color: isDark ? Colors.red[300] : Colors.red,
                      fontFamily: 'Roboto',
                    ),
                  ),
                );
              }

              final trends = snapshot.data ?? {};
              if (trends.isEmpty) {
                return const Center(
                  child: Text(
                    'No trend data available',
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                width: maxWidth - (isTablet ? 48 : 24), 
                child: Container(
                  child: TrendChartWidget(trends: trends, months: 6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}