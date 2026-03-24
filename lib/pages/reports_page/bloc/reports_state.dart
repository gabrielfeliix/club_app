part of 'reports_bloc.dart';

class KidAttendanceStats extends Equatable {
  final KidsModel kid;
  final int totalPresences;
  final int totalSessions;

  const KidAttendanceStats({
    required this.kid,
    required this.totalPresences,
    required this.totalSessions,
  });

  double get percentage => totalSessions == 0 ? 0 : totalPresences / totalSessions;

  @override
  List<Object?> get props => [kid, totalPresences, totalSessions];
}

class SessionChartData extends Equatable {
  final String date;
  final int totalPresent;

  const SessionChartData({required this.date, required this.totalPresent});

  @override
  List<Object?> get props => [date, totalPresent];
}

enum ReportsStatus { initial, loading, success, failure }

class ReportsBlocState extends Equatable {
  final ReportsStatus status;
  final String? message;
  final List<SessionChartData>? chartData;
  final List<KidAttendanceStats>? kidsStats;
  final List<SessionChartData>? decisionChartData;
  final List<DecisionModel>? recentDecisions;

  const ReportsBlocState._({
    required this.status,
    this.message,
    this.chartData,
    this.kidsStats,
    this.decisionChartData,
    this.recentDecisions,
  });

  const ReportsBlocState.initial() : this._(status: ReportsStatus.initial);

  const ReportsBlocState.loading() : this._(status: ReportsStatus.loading);

  const ReportsBlocState.success({
    required List<SessionChartData> chartData,
    required List<KidAttendanceStats> kidsStats,
    required List<SessionChartData> decisionChartData,
    required List<DecisionModel> recentDecisions,
  }) : this._(
          status: ReportsStatus.success,
          chartData: chartData,
          kidsStats: kidsStats,
          decisionChartData: decisionChartData,
          recentDecisions: recentDecisions,
        );

  const ReportsBlocState.failure({required String message})
      : this._(status: ReportsStatus.failure, message: message);

  bool get isInitial => status == ReportsStatus.initial;
  bool get isLoading => status == ReportsStatus.loading;
  bool get isSuccess => status == ReportsStatus.success;
  bool get isFailure => status == ReportsStatus.failure;

  @override
  List<Object?> get props => [status, message, chartData, kidsStats, decisionChartData, recentDecisions];
}
