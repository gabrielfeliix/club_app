part of 'reports_bloc.dart';

abstract class IReportsEvent extends Equatable {
  const IReportsEvent();

  @override
  List<Object> get props => [];
}

class LoadReportsRequired extends IReportsEvent {
  final String clubId;

  const LoadReportsRequired({required this.clubId});

  @override
  List<Object> get props => [clubId];
}
