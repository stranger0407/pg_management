import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/helpers.dart';

class DashboardScreen extends ConsumerWidget {
  final String buildingId;

  const DashboardScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsStreamProvider(buildingId));
    final expensesAsync = ref.watch(expensesStreamProvider(buildingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: paymentsAsync.when(
        data: (payments) => expensesAsync.when(
          data: (expenses) {
            final dashboard = ref.watch(dashboardProvider((
              buildingId: buildingId,
              payments: payments,
              expenses: expenses,
            )));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.4,
                    children: [
                      _summaryCard(
                        context,
                        title: 'Monthly Income',
                        amount: dashboard.monthlyIncome,
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                      _summaryCard(
                        context,
                        title: 'Monthly Expense',
                        amount: dashboard.monthlyExpense,
                        icon: Icons.trending_down,
                        color: Colors.red,
                      ),
                      _summaryCard(
                        context,
                        title: 'Net Profit',
                        amount: dashboard.netProfit,
                        icon: Icons.account_balance_wallet,
                        color: dashboard.netProfit >= 0
                            ? Colors.blue
                            : Colors.orange,
                      ),
                      _summaryCard(
                        context,
                        title: 'Pending Rent',
                        amount: dashboard.pendingRent,
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profit Chart
                  const Text(
                    '6-Month Profit Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: _buildChart(dashboard.profitHistory),
                  ),

                  const SizedBox(height: 24),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem('Income', Colors.green),
                      const SizedBox(width: 24),
                      _legendItem('Expense', Colors.red),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Helpers.formatCurrency(amount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<MonthlyProfit> profitHistory) {
    final maxIncome = profitHistory
        .map((e) => e.income)
        .fold<double>(0.0, (a, b) => a > b ? a : b);
    final maxExpense = profitHistory
        .map((e) => e.expense)
        .fold<double>(0.0, (a, b) => a > b ? a : b);
    final maxVal = (maxIncome > maxExpense ? maxIncome : maxExpense);
    final maxY = maxVal == 0 ? 1000.0 : maxVal * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = profitHistory[group.x.toInt()];
              final label = rodIndex == 0 ? 'Income' : 'Expense';
              final value = rodIndex == 0 ? month.income : month.expense;
              return BarTooltipItem(
                '$label\n${Helpers.formatCurrency(value)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < profitHistory.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      Helpers.getMonthName(profitHistory[index].month)
                          .substring(0, 3),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                String text;
                if (value >= 100000) {
                  text = '${(value / 100000).toStringAsFixed(1)}L';
                } else if (value >= 1000) {
                  text = '${(value / 1000).toStringAsFixed(0)}K';
                } else {
                  text = value.toStringAsFixed(0);
                }
                return Text(
                  text,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        barGroups: profitHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.income,
                color: Colors.green,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: data.expense,
                color: Colors.red,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
