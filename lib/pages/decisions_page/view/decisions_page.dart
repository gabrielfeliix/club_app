import 'package:app_ui/app_ui.dart';
import 'package:club_app/main.dart';
import 'package:club_app/routes/routes.dart';
import 'package:decision_repository/decision_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:club_app/pages/decisions_page/bloc/decisions_bloc.dart';
import 'package:intl/intl.dart';

class DecisionsPage extends StatelessWidget {
  final String id; // clubId
  const DecisionsPage({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DecisionsBloc(
        decisionRepository: getIt<IDecisionRepository>(),
      )..add(LoadDecisionsRequired(clubId: id)),
      child: DecisionsView(clubId: id),
    );
  }
}

class DecisionsView extends StatefulWidget {
  final String clubId;
  const DecisionsView({required this.clubId, super.key});

  @override
  State<DecisionsView> createState() => _DecisionsViewState();
}

class _DecisionsViewState extends State<DecisionsView> {
  DateTime? _selectedDateFilter;

  Future<void> _refreshDecisions() async {
    context.read<DecisionsBloc>().add(LoadDecisionsRequired(clubId: widget.clubId));
  }

  void _pickFilterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Filtrar por data',
    );
    if (picked != null) {
      setState(() => _selectedDateFilter = picked);
    }
  }

  void _clearFilter() {
    setState(() => _selectedDateFilter = null);
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decisões'),
        centerTitle: true,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        actions: [
          if (_selectedDateFilter != null)
            IconButton(
              icon: Icon(Icons.clear, color: context.colors.onPrimary),
              onPressed: _clearFilter,
              tooltip: 'Limpar Filtro',
            ),
          IconButton(
            icon: Icon(Icons.filter_list_alt, color: context.colors.onPrimary),
            onPressed: _pickFilterDate,
            tooltip: 'Filtrar Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('${AppRouter.addDecision}/${widget.clubId}').then((_) {
            // Reload when coming back
            context.read<DecisionsBloc>().add(LoadDecisionsRequired(clubId: widget.clubId));
          });
        },
        backgroundColor: context.colors.primary,
        child: Icon(Icons.add, color: context.colors.onPrimary),
      ),
      body: BlocConsumer<DecisionsBloc, DecisionsState>(
        listener: (context, state) {
          if (state.isFailure) {
            showCustomSnackBar(
              context,
              state.message ?? 'Erro ao carregar decisões.',
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.decisions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isFailure && state.decisions.isEmpty) {
            return Center(child: Text(state.message ?? 'Erro ao carregar decisões.'));
          }

          var filteredDecisions = state.decisions;
          if (_selectedDateFilter != null) {
            filteredDecisions = filteredDecisions
                .where((d) => _isSameDate(d.decisionDate, _selectedDateFilter!))
                .toList();
          }

          if (state.decisions.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshDecisions,
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  const Center(child: Text('Nenhuma decisão registrada.')),
                ],
              ),
            );
          }

          if (filteredDecisions.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshDecisions,
              child: ListView(
                children: [
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Filtro: ${DateFormat('dd/MM/yyyy').format(_selectedDateFilter!)}',
                      style: context.text.titleMedium?.copyWith(color: context.colors.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Text('Nenhuma decisão para esta data.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshDecisions,
            child: Column(
              children: [
                if (_selectedDateFilter != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mostrando decisões de: ${DateFormat('dd/MM/yyyy').format(_selectedDateFilter!)}',
                          style: context.text.titleMedium?.copyWith(color: context.colors.primary),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: _selectedDateFilter == null ? const EdgeInsets.all(16.0) : const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredDecisions.length,
                    itemBuilder: (context, index) {
                      final decision = filteredDecisions[index];
                      final formattedDate = DateFormat('dd/MM/yyyy').format(decision.decisionDate);

                      return Card(
                        elevation: 0,
                        color: context.colors.onSurface.withOpacity(0.05),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: context.colors.primary.withOpacity(0.1),
                            child: Text(
                              decision.childName.isNotEmpty
                                  ? decision.childName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(color: context.colors.primary),
                            ),
                          ),
                          title: Text(
                            decision.childName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.colors.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'Idade: ${decision.age} | Conselheiro: ${decision.counselorName}\n$formattedDate',
                            style: TextStyle(
                              color: context.colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                          isThreeLine: true,
                          trailing: Icon(
                            decision.isEnrolled
                                ? Icons.school
                                : decision.isVisitor
                                    ? Icons.emoji_people
                                    : Icons.person,
                            color: context.colors.primary,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: context.colors.surface,
                                  title: Text(decision.childName, style: context.text.titleLarge?.copyWith(color: context.colors.primary)),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Endereço: ${decision.address}', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurface)),
                                        const SizedBox(height: 8),
                                        Text('Idade: ${decision.age}', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurface)),
                                        const SizedBox(height: 8),
                                        Text('Telefone: ${decision.phone}', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurface)),
                                        const SizedBox(height: 8),
                                        Text('Conselheiro: ${decision.counselorName}', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurface)),
                                        const SizedBox(height: 8),
                                        Text('Data: $formattedDate', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurface)),
                                        const SizedBox(height: 8),
                                        Text('Status: ${decision.isEnrolled ? "Matriculada" : decision.isVisitor ? "Visitante" : "Não informado"}', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurface)),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Fechar', style: TextStyle(color: context.colors.primary)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
