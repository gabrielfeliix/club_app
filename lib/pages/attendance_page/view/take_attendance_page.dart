import 'package:app_ui/app_ui.dart';
import 'package:attendance_repository/attendance_repository.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/attendance_page/bloc/attendance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TakeAttendancePage extends StatelessWidget {
  final String id;
  final AttendanceModel? attendanceModel;
  const TakeAttendancePage({required this.id, this.attendanceModel, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = AttendanceBloc(attendanceRepository: getIt<IAttendanceRepository>());
        if (attendanceModel != null) {
          bloc.add(GetKidsForExistingAttendanceRequired(id: id, attendance: attendanceModel!));
        } else {
          bloc.add(GetAllKidsRequired(id: id));
        }
        return bloc;
      },
      child: TakeAttendanceView(id: id, isViewing: attendanceModel != null, sessionDate: attendanceModel?.date),
    );
  }
}

class TakeAttendanceView extends StatelessWidget {
  final String id;
  final bool isViewing;
  final String? sessionDate;
  const TakeAttendanceView({super.key, required this.id, this.isViewing = false, this.sessionDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isViewing ? 'Visualizar Chamada' : 'Chamada do clubinho'),
        centerTitle: true,
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceBlocState>(
        builder: _handlerBuilder,
        listener: _handlerListener,
      ),
    );
  }

  /// Dealing with bloc listening
  _handlerListener(BuildContext context, AttendanceBlocState state) {
    if (state.isFailure) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.error,
      );
    } else if (state.isSuccess && state.message != null && state.message!.isNotEmpty) {
      if (context.mounted) {
        context.pop(true);
      }
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.success,
      );
    }
  }

  /// Dealing with bloc builder
  Widget _handlerBuilder(BuildContext context, AttendanceBlocState state) {
    if (state.isSuccess) {
      return RefreshIndicator(
        onRefresh: () => _refreshKids(context, id),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: ListView.builder(
                  itemCount: state.kidsList!.length,
                  itemBuilder: (context, index) {
                    final kid = state.kidsList![index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.onBackground.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    kid.fullName.isNotEmpty ? kid.fullName : 'Aluno sem nome',
                                    style: context.text.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    kid.age.isNotEmpty ? '${kid.age} anos' : 'Idade não informada',
                                    style: context.text.bodyMedium?.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Checkbox(
                                      side: BorderSide(color: context.colors.primary.withOpacity(0.5), width: 1.5),
                                      value: kid.isPresent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (bool? value) {
                                        if (value == true) {
                                          context.read<AttendanceBloc>().add(
                                                ChangeRequired(
                                                  kidId: kid.id,
                                                  isPresent: true,
                                                  isAbsent: false,
                                                ),
                                              );
                                        } else {
                                          context.read<AttendanceBloc>().add(
                                                ChangeRequired(
                                                  kidId: kid.id,
                                                  isPresent: false,
                                                  isAbsent: false,
                                                ),
                                              );
                                        }
                                      },
                                      fillColor: MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return context.colors.primary;
                                        }
                                        return Colors.transparent;
                                      }),
                                      checkColor: context.colors.onPrimary,
                                    ),
                                    Text('Presente', style: context.text.labelSmall?.copyWith(fontSize: 10, color: Colors.black54)),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    Checkbox(
                                      side: BorderSide(color: context.colors.error.withOpacity(0.5), width: 1.5),
                                      value: kid.isAbsent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (bool? value) {
                                        if (value == true) {
                                          context.read<AttendanceBloc>().add(
                                                ChangeRequired(
                                                  kidId: kid.id,
                                                  isPresent: false,
                                                  isAbsent: true,
                                                ),
                                              );
                                        } else {
                                          context.read<AttendanceBloc>().add(
                                                ChangeRequired(
                                                  kidId: kid.id,
                                                  isPresent: false,
                                                  isAbsent: false,
                                                ),
                                              );
                                        }
                                      },
                                      fillColor: MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return context.colors.error;
                                        }
                                        return Colors.transparent;
                                      }),
                                      checkColor: context.colors.onError,
                                    ),
                                    Text('Faltou', style: context.text.labelSmall?.copyWith(fontSize: 10, color: Colors.black54)),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  height: 50,
                  isLoading: state.isLoading,
                  label: 'Salvar Chamada',
                  onPressed: () => context
                      .read<AttendanceBloc>()
                      .add(TakeAttendanceRequired(kidsList: state.kidsList!, date: sessionDate)),
                ),
              ),
          ],
        ),
      );
    } else if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return const Center(child: Text('Nenhuma Chamada Encontrada!'));
    }
  }

  /// Refreshes the list of clubs.
  Future<void> _refreshKids(BuildContext context, String id) async {
    context.read<AttendanceBloc>().add(GetAllKidsRequired(id: id));
  }
}
