import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:decision_repository/decision_repository.dart';

part 'decisions_event.dart';
part 'decisions_state.dart';

class DecisionsBloc extends Bloc<DecisionsEvent, DecisionsState> {
  final IDecisionRepository decisionRepository;

  DecisionsBloc({required this.decisionRepository}) : super(const DecisionsState()) {
    on<LoadDecisionsRequired>(_onLoadDecisions);
    on<CreateDecisionRequired>(_onCreateDecision);
  }

  Future<void> _onLoadDecisions(
    LoadDecisionsRequired event,
    Emitter<DecisionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, isFailure: false, clubId: event.clubId));
    final response = await decisionRepository.getDecisions(clubId: event.clubId);

    response.when(
      (decisions) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          decisions: decisions,
        ));
      },
      (error) {
        emit(state.copyWith(
          isLoading: false,
          isFailure: true,
          message: error.toString(),
        ));
      },
    );
  }

  Future<void> _onCreateDecision(
    CreateDecisionRequired event,
    Emitter<DecisionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, isFailure: false));
    final response = await decisionRepository.createDecision(decision: event.decision);

    response.when(
      (decision) {
        final List<DecisionModel> updatedDecisions = List.from(state.decisions)
          ..insert(0, decision);

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          decisions: updatedDecisions,
          message: 'Decisão salva com sucesso!',
        ));
      },
      (error) {
        emit(state.copyWith(
          isLoading: false,
          isFailure: true,
          message: 'Erro ao salvar decisão: ${error.toString()}',
        ));
      },
    );
  }
}
