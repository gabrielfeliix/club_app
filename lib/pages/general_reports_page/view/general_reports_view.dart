import 'package:app_ui/app_ui.dart';
import 'package:club_app/pages/general_reports_page/bloc/general_reports_bloc.dart';
import 'package:club_app/routes/routes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralReportsView extends StatelessWidget {
  const GeneralReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneralReportsBloc, GeneralReportsState>(
      builder: (context, state) {
        if (state.status == GeneralReportsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == GeneralReportsStatus.failure) {
          return Center(
              child: Text(state.message ?? 'Erro ao carregar dados.'));
        }
        if (state.status == GeneralReportsStatus.success) {
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<GeneralReportsBloc>()
                  .add(LoadGeneralReportsRequired());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(context, state),
                  const SizedBox(height: 32),
                  Text('Crescimento Consolidado',
                      style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSecondary.withOpacity(0.5))),
                  const SizedBox(height: 16),
                  _buildGrowthChart(context, state),
                  const SizedBox(height: 32),
                  Text('Todos os Clubinhos',
                      style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSecondary.withOpacity(0.5))),
                  const SizedBox(height: 16),
                  _buildClubsList(context, state),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, GeneralReportsState state) {
    return Row(
      children: [
        Expanded(
            child: _SummaryCard(
                label: 'Crianças',
                value: state.totalKids.toString(),
                icon: IconsaxPlusLinear.people,
                color: context.colors.primary)),
        const SizedBox(width: 8),
        Expanded(
            child: _SummaryCard(
                label: 'Decisões',
                value: state.totalDecisions.toString(),
                icon: IconsaxPlusBold.heart,
                color: Colors.redAccent)),
        const SizedBox(width: 8),
        Expanded(
            child: _SummaryCard(
                label: 'Retenção',
                value:
                    '${(state.globalRetentionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: Colors.green)),
      ],
    );
  }

  Widget _buildGrowthChart(BuildContext context, GeneralReportsState state) {
    return Card(
      elevation: 0,
      color: context.colors.onPrimary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.onSurface.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Evolução (3 Meses)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < 0 ||
                                  value.toInt() >= state.kidsGrowth.length)
                                return const SizedBox.shrink();
                              
                              final period = state.kidsGrowth[value.toInt()].period;
                              final month = int.parse(period.split('-')[1]);
                              const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                              
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(months[month - 1],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.colors.onSecondary.withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
                                    )),
                              );
                            })),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: context.colors.onSecondary.withOpacity(0.5),
                          ),
                        );
                      },
                    )),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: state.kidsGrowth
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.count.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: context.colors.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true,
                          color: context.colors.primary.withOpacity(0.1)),
                    ),
                    LineChartBarData(
                      spots: state.decisionsGrowth
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.count.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubsList(BuildContext context, GeneralReportsState state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.clubsSummaries.length,
      itemBuilder: (context, index) {
        final club = state.clubsSummaries[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: context.colors.onPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: context.colors.onSurface.withOpacity(0.05))),
          child: ListTile(
            onTap: () => context.push(AppRouter.reports, extra: club.id),
            title: Text(club.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${club.kidsCount} Crianças • ${club.decisionsCount} Decisões'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        '${(club.retentionRate * 100).toStringAsFixed(1)}% Ret.',
                        style: TextStyle(
                            fontSize: 12,
                            color: context.colors.onSurface.withOpacity(0.6))),
                    _buildTrendIcon(club.trend),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(IconsaxPlusLinear.arrow_right_2,
                    color: context.colors.onSurface.withOpacity(0.3)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendIcon(Trend trend) {
    switch (trend) {
      case Trend.up:
        return const Icon(IconsaxPlusLinear.trend_up, color: Colors.green, size: 16);
      case Trend.down:
        return const Icon(IconsaxPlusLinear.trend_down, color: Colors.red, size: 16);
      case Trend.stable:
        return const Icon(IconsaxPlusLinear.minus, color: Colors.orange, size: 16);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface)),
          Text(label,
              style: context.text.labelSmall
                  ?.copyWith(color: context.colors.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }
}
