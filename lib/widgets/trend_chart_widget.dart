import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TrendChartWidget extends StatefulWidget {
  final Map<String, Map<String, double>> trends;
  final int months;

  const TrendChartWidget({required this.trends, required this.months, Key? key, required bool isDark, required ColorScheme colorScheme})
      : super(key: key);

  @override
  _TrendChartWidgetState createState() => _TrendChartWidgetState();
}

class _TrendChartWidgetState extends State<TrendChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.trends.isEmpty) {
      return Center(
        child: Text(
          'No trend data available',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      );
    }

    final sortedKeys = widget.trends.keys.toList()..sort();
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final income = widget.trends[key]?['income'] ?? 0.0;
      final expenses = widget.trends[key]?['expenses'] ?? 0.0;
      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expenses));
    }

    if (incomeSpots.isEmpty || expenseSpots.isEmpty) {
      return Center(
        child: Text(
          'No valid trend data to plot',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      );
    }

    // Calculate maxY dynamically based on data
    final maxIncome = incomeSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxExpenses = expenseSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxY = (maxIncome > maxExpenses ? maxIncome : maxExpenses) * 1.2;

    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegend(isDark),
          const SizedBox(height: 6),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark ? Colors.grey[800]! : Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final month = sortedKeys[spot.x.toInt()];
                        final date = DateFormat('yyyy-MM').parse(month);
                        final value = spot.y.toStringAsFixed(2);
                        final type = spot.barIndex == 0 ? 'Income' : 'Expenses';
                        return LineTooltipItem(
                          '$type: \$$value\n${DateFormat.MMM().format(date)}',
                          TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: spot.barIndex == 0 ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: barData.color!.withOpacity(0.5),
                          strokeWidth: 2,
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                            radius: 6,
                            color: bar.color!,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= sortedKeys.length) {
                          return const Text('');
                        }
                        final date = DateFormat('yyyy-MM').parse(sortedKeys[value.toInt()]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat.MMM().format(date),
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 10,
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: maxY / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 0.5,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: incomeSpots,
                    isCurved: true,
                    color: Colors.green[700],
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green[700]!.withOpacity(0.3),
                          Colors.green[700]!.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseSpots,
                    isCurved: true,
                    color: Colors.red[700],
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red[700]!.withOpacity(0.3),
                          Colors.red[700]!.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxY > 0 ? maxY : 10.0, // Default to 10 if no data
              ),
              duration: const Duration(milliseconds: 600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: Colors.green[700]!,
          text: 'Income',
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: Colors.red[700]!,
          text: 'Expenses',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String text,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}