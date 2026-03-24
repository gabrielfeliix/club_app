part of 'general_reports_bloc.dart';

abstract class GeneralReportsEvent extends Equatable {
  const GeneralReportsEvent();

  @override
  List<Object> get props => [];
}

class LoadGeneralReportsRequired extends GeneralReportsEvent {}
