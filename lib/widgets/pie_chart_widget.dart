import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> categoryBreakdown;

  const PieChartWidget({required this.categoryBreakdown, Key? key, required List<Color> colorScheme})
    : super(key: key);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.categoryBreakdown.isEmpty) {
      return Center(
        child: Text(
          'No expenses to display',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14, // Smaller font
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      );
    }

    final total = widget.categoryBreakdown.values.fold(
      0.0,
      (sum, value) => sum + value,
    );
    final colors = [
      Colors.blue[700]!,
      Colors.red[700]!,
      Colors.green[700]!,
      Colors.yellow[700]!,
      Colors.purple[700]!,
      Colors.orange[700]!,
      Colors.teal[700]!,
      Colors.cyan[700]!,
    ];

    return Container(
      padding: const EdgeInsets.all(10), // Further reduced
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(12), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6, // Smaller shadow
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.6, // Further increased for compactness
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections:
                    widget.categoryBreakdown.entries.toList().asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final category = entry.value.key;
                      final value = entry.value.value;
                      final percentage = (value / total * 100).toStringAsFixed(
                        1,
                      );
                      final isTouched = index == touchedIndex;

                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: value,
                        title:
                            isTouched
                                ? '$category\n\$${value.toStringAsFixed(2)}\n$percentage%'
                                : '',
                        radius: isTouched ? 50 : 40, // Further reduced
                        titleStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: isTouched ? 12 : 10, // Smaller fonts
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        badgeWidget:
                            !isTouched
                                ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length]
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    category.length > 10
                                        ? '${category.substring(0, 7)}...'
                                        : category,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 8, // Smaller font
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                                : null,
                        badgePositionPercentageOffset: 1.0, // Closer badges
                      );
                    }).toList(),
                sectionsSpace: 2, // Reduced
                centerSpaceRadius: 40, // Smaller center
                startDegreeOffset: 270,
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
          const SizedBox(height: 6), // Further reduced
          _buildLegend(colors, widget.categoryBreakdown.keys.toList(), isDark),
        ],
      ),
    );
  }

  Widget _buildLegend(
    List<Color> colors,
    List<String> categories,
    bool isDark,
  ) {
    return Wrap(
      spacing: 10, // Further reduced
      runSpacing: 4, // Further reduced
      children:
          categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12, // Smaller dot
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5), // Reduced
                Text(
                  category.length > 10
                      ? '${category.substring(0, 7)}...'
                      : category,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11, // Smaller font
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}