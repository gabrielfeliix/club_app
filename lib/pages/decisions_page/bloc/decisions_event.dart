part of 'decisions_bloc.dart';

abstract class DecisionsEvent extends Equatable {
  const DecisionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDecisionsRequired extends DecisionsEvent {
  final String clubId;

  const LoadDecisionsRequired({required this.clubId});

  @override
  List<Object?> get props => [clubId];
}

class CreateDecisionRequired extends DecisionsEvent {
  final DecisionModel decision;

  const CreateDecisionRequired({required this.decision});

  @override
  List<Object?> get props => [decision];
}
