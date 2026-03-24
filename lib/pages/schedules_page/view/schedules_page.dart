import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/pages/schedules_page/bloc/schedule_bloc.dart';
import 'package:club_app/routes/routes.dart';
import 'package:club_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:schedule_repository/schedule_repository.dart';
import 'package:club_app/main.dart';

class SchedulesPage extends StatelessWidget {
  final String clubId;
  const SchedulesPage({required this.clubId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ScheduleBloc(scheduleRepository: getIt<IScheduleRepository>())
            ..add(LoadSchedulesRequired(clubId: clubId)),
      child: SchedulesView(clubId: clubId),
    );
  }
}

class SchedulesView extends StatelessWidget {
  final String clubId;
  const SchedulesView({required this.clubId, super.key});

  @override
  Widget build(BuildContext context) {
    final authUser =
        CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
    final isAuthorized = authUser?.userRole == UserRole.admin ||
        authUser?.userRole == UserRole.coordinator;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escalas do Clubinho'),
        centerTitle: true,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state.status == ScheduleStatus.success && state.schedules.isNotEmpty) {
            // Success loading handled by builder
          } else if (state.status == ScheduleStatus.failure) {
            showCustomSnackBar(
              context,
              state.errorMessage ?? 'Erro nas escalas.',
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          if (state.status == ScheduleStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ScheduleStatus.failure) {
            return Center(
                child: Text(state.errorMessage ?? 'Erro ao carregar escalas.'));
          }
          if (state.schedules.isEmpty) {
            return const Center(child: Text('Nenhuma escala criada.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<ScheduleBloc>()
                  .add(LoadSchedulesRequired(clubId: clubId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.schedules.length,
              itemBuilder: (context, index) {
                final schedule = state.schedules[index];
                return Card(
                  elevation: 0,
                  color: context.colors.onSurface.withOpacity(0.05),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      DateFormat('dd/MM/yyyy (EEEE)', 'pt_BR')
                          .format(schedule.date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                    ),
                    onTap: () async {
                      if (isAuthorized) {
                        // Load details and then go to form/view
                        final details = await getIt<IScheduleRepository>()
                            .getScheduleDetails(scheduleId: schedule.id);
                        if (context.mounted && details != null) {
                        context.push(AppRouter.scheduleForm, extra: {
                          'clubId': clubId,
                          'schedule': details,
                        }).then((_) {
                          if (context.mounted) {
                            context.read<ScheduleBloc>().add(LoadSchedulesRequired(clubId: clubId));
                          }
                        });
                        }
                      } else {
                        final details = await getIt<IScheduleRepository>()
                            .getScheduleDetails(scheduleId: schedule.id);
                        if (context.mounted && details != null) {
                          context.push(AppRouter.scheduleView, extra: details);
                        }
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAuthorized
          ? FloatingActionButton(
              onPressed: () {
                context.push(AppRouter.scheduleForm, extra: {
                  'clubId': clubId,
                  'schedule': null,
                }).then((_) {
                  if (context.mounted) {
                    context.read<ScheduleBloc>().add(LoadSchedulesRequired(clubId: clubId));
                  }
                });
              },
              backgroundColor: context.colors.primary,
              child: Icon(Icons.add, color: context.colors.onPrimary),
            )
          : null,
    );
  }
}
