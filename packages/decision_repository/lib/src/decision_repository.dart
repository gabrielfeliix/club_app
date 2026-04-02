import 'package:multiple_result/multiple_result.dart';
import 'package:decision_repository/src/models/decision_model.dart';

abstract class IDecisionRepository {
  /// Fetches a list of decisions for a specific club.
  Future<Result<List<DecisionModel>, Exception>> getDecisions({required String clubId});

  /// Adds a new decision to the database.
  Future<Result<DecisionModel, Exception>> createDecision({required DecisionModel decision});

  /// Fetches all decisions from all clubs (Admin only) or from specified clubs.
  Future<Result<List<DecisionModel>, Exception>> getAllDecisionsGlobal({List<String>? clubIds});
}
