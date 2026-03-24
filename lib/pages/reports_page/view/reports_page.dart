import 'package:app_ui/app_ui.dart';
import 'package:attendance_repository/attendance_repository.dart';
import 'package:decision_repository/decision_repository.dart';
import 'package:club_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:club_app/pages/reports_page/bloc/reports_bloc.dart';

class ReportsPage extends StatelessWidget {
  final String id;
  const ReportsPage({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsBloc(
        attendanceRepository: getIt<IAttendanceRepository>(),
        decisionRepository: getIt<IDecisionRepository>(),
      )..add(LoadReportsRequired(clubId: id)),
      child: ReportsView(id: id),
    );
  }
}

class ReportsView extends StatelessWidget {
  final String id;
  const ReportsView({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral e Relatórios'),
        centerTitle: true,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      body: BlocConsumer<ReportsBloc, ReportsBlocState>(
        listener: (context, state) {
          if (state.isFailure) {
            showCustomSnackBar(
              context,
              state.message ?? 'Erro ao carregar relatórios.',
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isFailure) {
            return Center(child: Text(state.message ?? 'Erro desconhecido.'));
          }
          if (state.isSuccess) {
            final chartData = state.chartData ?? [];
            final kidsStats = state.kidsStats ?? [];
            final decisionChartData = state.decisionChartData ?? [];
            final recentDecisions = state.recentDecisions ?? [];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- FREQUENCY SECTION ---
                    Text('Frequência (Últimas 7 Chamadas)',
                        style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface)),
                    const SizedBox(height: 24),
                    if (chartData.isEmpty)
                      const Center(child: Text('Nenhum dado de frequência.'))
                    else
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: kidsStats.isNotEmpty
                                ? kidsStats.length.toDouble()
                                : 10,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= chartData.length ||
                                        value.toInt() < 0) {
                                      return const SizedBox.shrink();
                                    }
                                    final date = chartData[value.toInt()].date;
                                    final shortDate = date
                                        .split('-')
                                        .reversed
                                        .take(2)
                                        .join('/');
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(shortDate,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: context.colors.onSurface
                                                  .withOpacity(0.6))),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 5,
                              getDrawingHorizontalLine: (value) => FlLine(
                                  color:
                                      context.colors.onSurface.withOpacity(0.1),
                                  strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: chartData.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.totalPresent.toDouble(),
                                    color: context.colors.primary,
                                    width: 16,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Text('Desempenho por Aluno',
                        style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface)),
                    const SizedBox(height: 16),
                    if (kidsStats.isEmpty)
                      const Center(child: Text('Nenhum aluno cadastrado.'))
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: kidsStats.length,
                        itemBuilder: (context, index) {
                          final stat = kidsStats[index];
                          return Card(
                            elevation: 0,
                            color: context.colors.onSurface.withOpacity(0.05),
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    context.colors.primary.withOpacity(0.1),
                                child: Text(
                                  stat.kid.fullName.isNotEmpty
                                      ? stat.kid.fullName[0].toUpperCase()
                                      : 'A',
                                  style:
                                      TextStyle(color: context.colors.primary),
                                ),
                              ),
                              title: Text(
                                  stat.kid.fullName.isNotEmpty
                                      ? stat.kid.fullName
                                      : 'Sem nome',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.onSurface)),
                              subtitle: Text(
                                  '${stat.totalPresences} / ${stat.totalSessions} presenças (${(stat.percentage * 100).toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                      color: context.colors.onSurface
                                          .withOpacity(0.6))),
                              trailing: CircularProgressIndicator(
                                value: stat.percentage,
                                backgroundColor:
                                    context.colors.onSurface.withOpacity(0.1),
                                color: stat.percentage > 0.7
                                    ? context.colors.primary
                                    : context.colors.error,
                              ),
                            ),
                          );
                        },
                      ),

                    // --- DECISIONS SECTION ---
                    const SizedBox(height: 48),
                    Text('Decisões (Últimos 6 Meses)',
                        style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface)),
                    const SizedBox(height: 24),
                    if (decisionChartData.isEmpty)
                      const Center(child: Text('Nenhuma decisão registrada.'))
                    else
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxY(decisionChartData),
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >=
                                            decisionChartData.length ||
                                        value.toInt() < 0) {
                                      return const SizedBox.shrink();
                                    }
                                    final dateParts =
                                        decisionChartData[value.toInt()]
                                            .date
                                            .split('-');
                                    final label =
                                        '${dateParts[1]}/${dateParts[0].substring(2)}'; // MM/YY
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(label,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: context.colors.onSurface
                                                  .withOpacity(0.6))),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 5,
                              getDrawingHorizontalLine: (value) => FlLine(
                                  color:
                                      context.colors.onSurface.withOpacity(0.1),
                                  strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups:
                                decisionChartData.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.totalPresent.toDouble(),
                                    color: context.colors.primary,
                                    width: 16,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Text('Últimas Decisões',
                        style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface)),
                    const SizedBox(height: 16),
                    if (recentDecisions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                            child: Text(
                                'Nenhuma decisão registrada recentemente.')),
                      )
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: recentDecisions.length,
                        itemBuilder: (context, index) {
                          final decision = recentDecisions[index];
                          return Card(
                            elevation: 0,
                            color: context.colors.onSurface.withOpacity(0.05),
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    context.colors.primary.withOpacity(0.1),
                                child: Text(
                                  decision.childName.isNotEmpty
                                      ? decision.childName[0].toUpperCase()
                                      : '?',
                                  style:
                                      TextStyle(color: context.colors.primary),
                                ),
                              ),
                              title: Text(decision.childName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.onSurface)),
                              subtitle: Text(
                                'Data: ${DateFormat('dd/MM/yyyy').format(decision.decisionDate)}\nConselheiro: ${decision.counselorName}',
                                style: TextStyle(
                                    color: context.colors.onSurface
                                        .withOpacity(0.6)),
                              ),
                              isThreeLine: true,
                              trailing: Icon(
                                decision.isEnrolled
                                    ? Icons.school
                                    : Icons.person,
                                color: context.colors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  double _getMaxY(List<SessionChartData> data) {
    if (data.isEmpty) return 10;
    double max = 0;
    for (var d in data) {
      if (d.totalPresent > max) max = d.totalPresent.toDouble();
    }
    return max + 2;
  }
}
