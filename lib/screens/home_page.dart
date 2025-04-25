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
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final List<Widget> _pages = [
    SummaryPage(),
    AddEntryPage(),
    HistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await _authService.logout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Budget Tracker', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageCategoriesPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Budget Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetSettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
              child: Column(
                children: [
                  _pages[_selectedIndex],
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income vs Expenses Trend',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        StreamBuilder<Map<String, dynamic>>(
                          stream: _firestoreService.getMonthlyTrends(6),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }
                            return TrendChartWidget(
                              trends: (snapshot.data!).map(
                                (key, value) => MapEntry(
                                  key,
                                  (value as Map<dynamic, dynamic>).map(
                                    (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
                                  ),
                                ),
                              ),
                              months: 6,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Entry'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}