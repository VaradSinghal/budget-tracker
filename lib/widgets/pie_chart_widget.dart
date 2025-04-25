import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> categoryBreakdown;

  const PieChartWidget({required this.categoryBreakdown});

  @override
  Widget build(BuildContext context) {
    if (categoryBreakdown.isEmpty) {
      return const Center(child: Text('No expenses to display'));
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return PieChart(
      PieChartData(
        sections:
            categoryBreakdown.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value.key;
              final value = entry.value.value;

              return PieChartSectionData(
                color: colors[index % colors.length],
                value: value,
                title: category,
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              );
            }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
