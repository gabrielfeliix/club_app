part of 'decisions_bloc.dart';

class DecisionsState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final bool isFailure;
  final String? message;
  final List<DecisionModel> decisions;
  final String clubId;

  const DecisionsState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.message,
    this.decisions = const [],
    this.clubId = '',
  });

  DecisionsState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isFailure,
    String? message,
    List<DecisionModel>? decisions,
    String? clubId,
  }) {
    return DecisionsState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      message: message,
      decisions: decisions ?? this.decisions,
      clubId: clubId ?? this.clubId,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isSuccess, isFailure, message, decisions, clubId];
}
