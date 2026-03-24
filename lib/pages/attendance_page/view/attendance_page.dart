import 'package:app_ui/app_ui.dart';
import 'package:attendance_repository/attendance_repository.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/attendance_page/bloc/attendance_bloc.dart';
import 'package:club_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AttendancePage extends StatelessWidget {
  final String id;
  const AttendancePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AttendanceBloc(attendanceRepository: getIt<IAttendanceRepository>())
            ..add(
              GetAllAttendanceRequired(id: id),
            ),
      child: AttendanceViews(id: id),
    );
  }
}

class AttendanceViews extends StatelessWidget {
  final String id;
  const AttendanceViews({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chamadas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onTapTakeAttendance(context),
        child: const Icon(Icons.add),
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
        onRefresh: () => _refreshAtt(context, id),
        child: ListView.builder(
          itemCount: state.attendanceList!.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(state.attendanceList![index].date),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final result = await context.push<bool>(
                  AppRouter.takeAttendance,
                  extra: {
                    'clubId': id,
                    'attendanceModel': state.attendanceList![index],
                  },
                );
                if (result == true && context.mounted) {
                  _refreshAtt(context, id);
                }
              },
            );
          },
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
  Future<void> _refreshAtt(BuildContext context, String id) async {
    context.read<AttendanceBloc>().add(GetAllAttendanceRequired(id: id));
  }

  /// Navigates to the take attendance children when is triggered.
  onTapTakeAttendance(BuildContext context) async {
    final result = await context.push<bool>(AppRouter.takeAttendance, extra: id);
    if (result == true && context.mounted) {
      _refreshAtt(context, id);
    }
  }
}
