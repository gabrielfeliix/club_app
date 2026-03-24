import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/pages/users_manage/bloc/users_manage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// class UsersManagePage extends StatelessWidget {
//   const UsersManagePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => UsersManageBloc(
//         authenticationRepository: getIt<IAuthenticationRepository>(),
//       )..add(GetAllUsersRequired()),
//       child: const UsersManageView(),
//     );
//   }
// }

class UsersManageView extends StatelessWidget {
  const UsersManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UsersManageBloc, UsersManageState>(
        listener: _handlerListener,
        builder: _handlerBuilder,
      ),
    );
  }

  /// Dealing with bloc listening
  _handlerListener(BuildContext context, UsersManageState state) {
    if (state.isFailure) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.error,
      );
    } else if (state.isLoaded) {
      //showCustomSnackBar(context, 'Carregado!');
    } else if (state.isSuccess) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.success,
      );
    }
  }

  /// Dealing with bloc builder
  Widget _handlerBuilder(BuildContext context, UsersManageState state) {
    if (state.teachers != null) {
      return RefreshIndicator(
        onRefresh: () => _refreshUsers(context),
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: state.teachers!.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = state.teachers![index];
            return Card(
              color: context.theme.colorScheme.onPrimary,
              elevation: 4,
              shadowColor: context.colors.onSurface.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: context.colors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: context.colors.primary,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      user.email,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: user.userRole,
                        dropdownColor: context.theme.colorScheme.onPrimary,
                        icon: Icon(Icons.arrow_drop_down,
                            color: context.colors.primary),
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        onChanged: (role) {
                          if (role != null && role != user.userRole) {
                            _buildAlertDialog(context, role, user.id);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: UserRole.teacher,
                            child: Text('Teacher'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.coordinator,
                            child: Text('Coordinator'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.admin,
                            child: Text('Admin'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state.isEmpty) {
      return const Center(child: Text('Nenhum usuário encontrado!'));
    } else {
      return const Center(child: Text('Nenhum Usuário Vinculado!'));
    }
  }

  /// Section Widget
  _buildAlertDialog(BuildContext context, UserRole role, String id) {
    final bloc = context.read<UsersManageBloc>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: bloc,
          child: BlocConsumer<UsersManageBloc, UsersManageState>(
            listener: (context, state) {
              if (state.isFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                  ),
                );
              }
            },
            builder: (context, state) {
              return AlertDialog(
                backgroundColor: context.theme.colorScheme.onPrimary,
                title: const Text('Alterar role, tem certeza?'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    state.isLoading
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.read<UsersManageBloc>().add(
                            ChangeRoleRequired(role: role, userId: id),
                          );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Sim'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Não'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Refreshes the list of clubs.
  Future<void> _refreshUsers(BuildContext context) async {
    context.read<UsersManageBloc>().add(GetAllUsersRequired());
  }
}
