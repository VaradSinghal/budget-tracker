import 'package:flutter/material.dart';
import 'package:budget_tracker/screens/add_entry_page.dart';
import 'package:budget_tracker/screens/history_page.dart';
import 'package:budget_tracker/screens/summary_page.dart';
import 'package:budget_tracker/screens/manage_categories_page.dart';
import 'package:budget_tracker/screens/budget_settings_page.dart';
import 'package:budget_tracker/services/auth_service.dart';
import 'package:budget_tracker/widgets/trend_chart_widget.dart';
import 'package:budget_tracker/services/firestore_service.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _chartTitleController.forward(from: 0);
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _logout() async {
    await _authService.logout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Budget Tracker',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(isDark),
      // Use IndexedStack to maintain state across tab changes
      body:
          _selectedIndex == 0
              ? _buildHomeTab(isDark)
              : IndexedStack(
                index: _selectedIndex - 1,
                sizing: StackFit.expand,
                children: const [AddEntryPage(), HistoryPage()],
              ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }

  Widget _buildHomeTab(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendChartCard(context, isDark),
          const SizedBox(height: 16),

          // Use a Container with constraints to prevent layout issues
          Container(
            constraints: BoxConstraints(
              // Use MediaQuery to get screen height and set a minimum height
              minHeight: MediaQuery.of(context).size.height - 300,
            ),
            child: SummaryPage(),
          ),

          // Add bottom padding for navigation bar
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(isDark),
          _buildDrawerTile(
            isDark: isDark,
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
            isDark: isDark,
            title: 'Budget Settings',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetSettingsPage(),
                ),
              );
            },
          ),
          const Divider(height: 32, indent: 16, endIndent: 16),
          _buildDrawerTile(
            isDark: isDark,
            title: 'Logout',
            icon: Icons.logout,
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[200],
      ),
      child: AnimatedBuilder(
        animation: _drawerHeaderController,
        builder: (context, child) {
          return Transform.scale(
            scale: _drawerHeaderScaleAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[600] : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 40,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Budget Tracker',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerTile({
    required bool isDark,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white : Colors.black),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white54 : Colors.black54,
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: GNav(
            rippleColor: isDark ? Colors.grey[600]! : Colors.grey[300]!,
            hoverColor: isDark ? Colors.grey[600]! : Colors.grey[300]!,
            gap: 8,
            activeColor: isDark ? Colors.white : Colors.black,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 300),
            color: isDark ? Colors.white70 : Colors.black54,
            tabBackgroundColor: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            tabs: const [
              GButton(icon: Icons.pie_chart, text: 'Summary'),
              GButton(icon: Icons.add, text: 'Add Entry'),
              GButton(icon: Icons.history, text: 'History'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendChartCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
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
                child: Text(
                  'Income vs Expenses Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<Map<String, Map<String, double>>>(
            stream: _firestoreService.getMonthlyTrends(6),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading trends',
                    style: TextStyle(
                      color: isDark ? Colors.red[300] : Colors.red,
                    ),
                  ),
                );
              }

              final trends = snapshot.data ?? {};
              if (trends.isEmpty) {
                return Center(
                  child: Text(
                    'No trend data available',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: TrendChartWidget(
                  trends: trends,
                  months: 6,
                  isDark: isDark,
                  colorScheme: Theme.of(context).colorScheme,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}