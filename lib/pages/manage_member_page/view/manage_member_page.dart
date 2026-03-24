import 'package:app_ui/app_ui.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/manage_member_page/bloc/manage_member_bloc.dart';
import 'package:club_app/routes/routes.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/utils/constants.dart';
import 'package:club_repository/club_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ManageMemberPage extends StatelessWidget {
  const ManageMemberPage.teachers({required this.id, super.key})
      : isTeacher = true;

  const ManageMemberPage.children({required this.id, super.key})
      : isTeacher = false;

  final bool isTeacher;

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ManageMemberBloc(clubRepository: getIt<IClubRepository>());
        _initializeBloc(bloc);
        return bloc;
      },
      child: ManageUsersView(isTeacher: isTeacher, id: id),
    );
  }

  /// Dealing bloc initialize
  void _initializeBloc(ManageMemberBloc bloc) {
    final event = isTeacher
        ? GetTeatchersRequired(id: id)
        : //
        GetChildrenRequired(id: id);

    bloc.add(event);
  }
}

// ignore: must_be_immutable
class ManageUsersView extends StatelessWidget {
  const ManageUsersView({super.key, required this.isTeacher, required this.id});

  final bool isTeacher;

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<ManageMemberBloc, ManageMemberState>(
          builder: (context, state) => myAppbar(state, isTeacher),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, id),
      body: BlocConsumer<ManageMemberBloc, ManageMemberState>(
        builder: _handlerBuilder,
        listener: _handlerListener,
      ),
    );
  }

  /// Dealing with bloc listening
  _handlerListener(BuildContext context, ManageMemberState state) {
    if (state.isFailure) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.error,
      );
    } else if (state.isLoaded) {
      showCustomSnackBar(
        context,
        'Carregado!',
        type: SnackBarType.success,
      );
    }
  }

  /// Dealing with bloc builder
  Widget _handlerBuilder(BuildContext context, ManageMemberState state) {
    if (state.isLoaded) {
      return RefreshIndicator(
        onRefresh: () => isTeacher
            ? _refreshTeachers(context, id)
            : _refreshKids(context, id),
        child: ListView.builder(
          itemCount: isTeacher
              ? state.teatchersModel!.length
              : state.childrenModel!.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(isTeacher
                  ? state.teatchersModel![index].name
                  : state.childrenModel![index].fullName),
              subtitle: Text(isTeacher
                  ? state.teatchersModel![index].contact
                  : "${state.childrenModel![index].age} anos"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => isTeacher
                  ? onTapUserInfo(context, state.teatchersModel![index], id)
                  : onTapChildInfo(context, state.childrenModel![index], id),
            );
          },
        ),
      );
    } else if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return const Center(child: Text('Nenhum Professor Vinculado!'));
    }
  }

  /// Section Widget
  PreferredSizeWidget myAppbar(ManageMemberState state, bool isTeacher) {
    return AppBar(
      title: Text(
          '${isTeacher ? 'Membros' : 'Crianças'} : ${isTeacher ? state.teatchersModel?.length ?? 0 : state.childrenModel?.length ?? 0}'),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
    );
  }

  /// Navigates to the child registration when the action is triggered.
  onTapChildRegistration(BuildContext context, String id) {
    context.push(AppRouter.childRegistration, extra: id);
  }

  /// Section Widget
  Widget? _buildFloatingActionButton(BuildContext context, String id) {
    final authUser =
        CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
    final bool isAdminOrCoordinator = authUser?.userRole == UserRole.admin ||
        authUser?.userRole == UserRole.coordinator;

    if (!isTeacher) {
      // Button to add Children
      return FloatingActionButton(
        onPressed: () => onTapChildRegistration(context, id),
        shape: const CircleBorder(),
        backgroundColor: context.colors.primary,
        child: Icon(Icons.person_add_alt_1_rounded,
            color: context.colors.onPrimary),
      );
    } else if (isAdminOrCoordinator) {
      // Button to add Teachers
      return FloatingActionButton(
        onPressed: () => _showAddTeacherDialog(context, id),
        shape: const CircleBorder(),
        backgroundColor: context.colors.primary,
        child: Icon(Icons.person_add_alt_1_rounded,
            color: context.colors.onPrimary),
      );
    }

    return null;
  }

  void _showAddTeacherDialog(BuildContext context, String clubId) {
    final bloc = context.read<ManageMemberBloc>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: context.theme.colorScheme.onPrimary,
          title: Text(
            'Adicionar Professor',
            style: context.text.headlineMedium?.copyWith(
              color: context.colors.onSecondary,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.4,
            child: FutureBuilder(
              future: getIt<IAuthenticationRepository>().getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Erro ao buscar professores'));
                }

                final result = snapshot.data!;
                return result.when(
                  (users) {
                    final filteredUsers = users.where((u) => u.userRole != UserRole.admin).toList();

                    if (filteredUsers.isEmpty) {
                      return const Center(child: Text('Nenhum professor disponível encontrado'));
                    }
                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () {
                            bloc.add(AddTeacherToClubRequired(
                                teacherId: user.id, clubId: clubId));
                            Navigator.pop(dialogContext);
                          },
                        );
                      },
                    );
                  },
                  (err) => Center(child: Text(err.message)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  /// Navigates to the user information when the action is triggered.
  onTapUserInfo(BuildContext context, TeachersModel model, String id) {
    context.push(
      AppRouter.userInformation,
      extra: model.copyWith(clubIdSave: id),
    );
  }

  /// Navigates to the user information when the action is triggered.
  onTapChildInfo(BuildContext context, KidsModel model, String id) {
    context.push(
      AppRouter.childInformation,
      extra: model.copyWith(clubIdSave: id),
    );
  }

  /// Refreshes the list of kids.
  Future<void> _refreshKids(BuildContext context, String id) async {
    context.read<ManageMemberBloc>().add(GetChildrenRequired(id: id));
  }

  /// Refreshes the list of teacher.
  Future<void> _refreshTeachers(BuildContext context, String id) async {
    context.read<ManageMemberBloc>().add(GetTeatchersRequired(id: id));
  }
}
