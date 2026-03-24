part of 'general_reports_bloc.dart';

enum GeneralReportsStatus { initial, loading, success, failure }

enum Trend { up, down, stable }

class ClubSummary extends Equatable {
  final String id;
  final String name;
  final int kidsCount;
  final int decisionsCount;
  final double retentionRate;
  final Trend trend;

  const ClubSummary({
    required this.id,
    required this.name,
    required this.kidsCount,
    required this.decisionsCount,
    required this.retentionRate,
    required this.trend,
  });

  @override
  List<Object?> get props => [id, name, kidsCount, decisionsCount, retentionRate, trend];
}

class GrowthData extends Equatable {
  final String period; // e.g., "2024-03"
  final int count;

  const GrowthData({required this.period, required this.count});

  @override
  List<Object?> get props => [period, count];
}

class GeneralReportsState extends Equatable {
  final GeneralReportsStatus status;
  final String? message;
  final int totalKids;
  final int totalDecisions;
  final double globalRetentionRate;
  final List<GrowthData> kidsGrowth;
  final List<GrowthData> decisionsGrowth;
  final List<ClubSummary> clubsSummaries;

  const GeneralReportsState._({
    required this.status,
    this.message,
    this.totalKids = 0,
    this.totalDecisions = 0,
    this.globalRetentionRate = 0,
    this.kidsGrowth = const [],
    this.decisionsGrowth = const [],
    this.clubsSummaries = const [],
  });

  const GeneralReportsState.initial() : this._(status: GeneralReportsStatus.initial);
  const GeneralReportsState.loading() : this._(status: GeneralReportsStatus.loading);
  const GeneralReportsState.failure(String message) : this._(status: GeneralReportsStatus.failure, message: message);
  const GeneralReportsState.success({
    required int totalKids,
    required int totalDecisions,
    required double globalRetentionRate,
    required List<GrowthData> kidsGrowth,
    required List<GrowthData> decisionsGrowth,
    required List<ClubSummary> clubsSummaries,
  }) : this._(
          status: GeneralReportsStatus.success,
          totalKids: totalKids,
          totalDecisions: totalDecisions,
          globalRetentionRate: globalRetentionRate,
          kidsGrowth: kidsGrowth,
          decisionsGrowth: decisionsGrowth,
          clubsSummaries: clubsSummaries,
        );

  @override
  List<Object?> get props => [
        status,
        message,
        totalKids,
        totalDecisions,
        globalRetentionRate,
        kidsGrowth,
        decisionsGrowth,
        clubsSummaries,
      ];
}
