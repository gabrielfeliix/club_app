import 'dart:developer';
import 'package:multiple_result/multiple_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:decision_repository/src/decision_repository.dart';
import 'package:decision_repository/src/models/decision_model.dart';

class SupabaseDecisionRepository implements IDecisionRepository {
  final SupabaseClient supabaseClient;

  SupabaseDecisionRepository({SupabaseClient? supabaseClient})
      : supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Result<List<DecisionModel>, Exception>> getDecisions({required String clubId}) async {
    try {
      final response = await supabaseClient
          .from('decisions')
          .select()
          .eq('club_id', clubId)
          .order('decision_date', ascending: false);

      final List<DecisionModel> decisions = response
          .map<DecisionModel>((json) => DecisionModel.fromJson(json))
          .toList();

      return Success(decisions);
    } catch (e, stackTrace) {
      log('Error fetching decisions from Supabase: $e', stackTrace: stackTrace);
      return Error(Exception('Failed to fetch decisions: $e'));
    }
  }

  @override
  Future<Result<DecisionModel, Exception>> createDecision({required DecisionModel decision}) async {
    try {
      final data = decision.toJson();
      
      final response = await supabaseClient
          .from('decisions')
          .insert(data)
          .select()
          .single();

      return Success(DecisionModel.fromJson(response));
    } catch (e, stackTrace) {
      log('Error creating decision in Supabase: $e', stackTrace: stackTrace);
      return Error(Exception('Failed to create decision: $e'));
    }
  }

  @override
  Future<Result<List<DecisionModel>, Exception>> getAllDecisionsGlobal(
      {List<String>? clubIds}) async {
    try {
      if (clubIds != null && clubIds.isEmpty) return const Success([]);

      var query = supabaseClient.from('decisions').select();

      if (clubIds != null) {
        query = query.filter('club_id', 'in', clubIds);
      }

      final response = await query.order('decision_date', ascending: false);

      final List<DecisionModel> decisions = response
          .map<DecisionModel>((json) => DecisionModel.fromJson(json))
          .toList();

      return Success(decisions);
    } catch (e, stackTrace) {
      log('Error fetching all decisions from Supabase: $e',
          stackTrace: stackTrace);
      return Error(Exception('Failed to fetch all decisions: $e'));
    }
  }
}
