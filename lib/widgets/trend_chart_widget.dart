import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TrendChartWidget extends StatelessWidget {
  final Map<String, Map<String, double>> trends;
  final int months;

  const TrendChartWidget({required this.trends, required this.months});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    final sortedKeys = trends.keys.toList()..sort();
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      incomeSpots.add(FlSpot(i.toDouble(), trends[key]!['income']!));
      expenseSpots.add(FlSpot(i.toDouble(), trends[key]!['expenses']!));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= sortedKeys.length) return const Text('');
                  final date = DateFormat('yyyy-MM').parse(sortedKeys[value.toInt()]);
                  return Text(DateFormat.MMM().format(date));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('\$${value.toInt()}');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}