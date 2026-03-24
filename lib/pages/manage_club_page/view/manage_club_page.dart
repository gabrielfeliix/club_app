import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/manage_club_page/bloc/manage_club_bloc.dart';
import 'package:club_app/routes/routes.dart';
import 'package:club_app/utils/constants.dart';
import 'package:club_app/utils/helpers.dart';
import 'package:club_repository/club_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ManageClubPage extends StatelessWidget {
  const ManageClubPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ManageClubBloc(clubRepository: getIt<IClubRepository>())
            ..add(GetClubDataRequired(id: id)),
      child: const ManageClubView(),
    );
  }
}
//? TO DO
//! Botão de tem certeza pra excluir clubin

class ManageClubView extends StatelessWidget {
  const ManageClubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      appBar: AppBar(
        // leading: SizedBox(
        //   child: Image.asset(
        //     'assets/logo_ibavin.png',
        //     filterQuality: FilterQuality.high,
        //     fit: BoxFit.contain,
        //   ),
        // ),
        title: Text(
          'Configurações',
          style: TextStyle(color: context.colors.onPrimary),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: context.colors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: BlocConsumer<ManageClubBloc, ManageClubBlocState>(
            listener: (context, state) {},
            builder: _handlerBuilder,
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildRoundedSquare(BuildContext context, String title, String id,
      void Function()? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.onSurface.withOpacity(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: context.colors.onPrimary,
                fontSize: 20,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              child: Image.asset(
                'assets/icons/wired-outline-1531-rocking-horse-hover-pinch.png',
                filterQuality: FilterQuality.high,
                fit: BoxFit.contain,
                height: 106,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 13),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(10.2),
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: context.colors.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dealing with bloc builder
  Widget _handlerBuilder(BuildContext context, ManageClubBlocState state) {
    final authUser =
        CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
    final bool isAdmin = authUser?.userRole == UserRole.admin;

    if (state.isLoading) {
      return const CircularProgressIndicator();
    } else if (state.isLoaded) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              height: 150,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 140,
              child: Card(
                child: Column(
                  children: [
                    const Text("Name 🖊️ "),
                    Text(
                      Helpers.capitalizeEachWord(state.clubModel!.name),
                    ),
                    const Text("Endereço 🖊️"),
                    Text(
                      Helpers.capitalizeEachWord(
                        state.clubModel!.address,
                      ),
                    ),
                    const Text("Código"),
                    Text(
                      Helpers.splitName(
                        state.clubModel!.id,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 1.5,
                  mainAxisSpacing: 1.5,
                ),
                padding: const EdgeInsets.all(10),
                children: [
                  _buildRoundedSquare(
                    context,
                    "Professores",
                    state.clubModel!.id,
                    () => onTapManageTeacher(context, state.clubModel!.id),
                  ),
                  _buildRoundedSquare(
                    context,
                    "Crianças",
                    state.clubModel!.id,
                    () => onTapManagechildren(context, state.clubModel!.id),
                  ),
                  _buildRoundedSquare(
                    context,
                    "Relatórios",
                    state.clubModel!.id,
                    () => context.push(AppRouter.reports, extra: state.clubModel!.id),
                  ),
                  _buildRoundedSquare(
                    context,
                    "Chamada",
                    state.clubModel!.id,
                    () => onTapAttendancechildren(
                      context,
                      state.clubModel!.id,
                    ),
                  ),
                  _buildRoundedSquare(
                    context,
                    "Decisões",
                    state.clubModel!.id,
                    () => context.push(AppRouter.decisions, extra: state.clubModel!.id),
                  ),
                  _buildRoundedSquare(
                    context,
                    "Escala",
                    state.clubModel!.id,
                    () => context.push(AppRouter.schedules, extra: state.clubModel!.id),
                  ),
                  _buildRoundedSquare(
                    context,
                    "Material \nde Apoio",
                    state.clubModel!.id,
                    () => null,
                  ),
                ],
              ),
            ),
            if (isAdmin)
              ElevatedButton(
                onPressed: () => context
                    .read<ManageClubBloc>()
                    .add(DeleteClubRequired(id: state.clubModel!.id)),
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red)),
                child: const Text(
                  'Apagar clubinho',
                  style: TextStyle(color: Colors.white),
                ),
              )
          ],
        ),
      );
    } else if (state.isDeleted) {
      return const Center(child: Text("Clubinho deletado com sucesso"));
    } else {
      return const Center(child: Text("Erro"));
    }
  }

  /// Navigates to the manage Teacher when trigger is performed.
  onTapManageTeacher(BuildContext context, String id) {
    context.push(AppRouter.manageMembers, extra: id);
  }

  /// Navigates to the manage children when trigger is performed.
  onTapManagechildren(BuildContext context, String id) {
    context.push(AppRouter.manageChildren, extra: id);
  }

  /// Navigates to the attendance children when trigger is performed.
  onTapAttendancechildren(BuildContext context, String id) {
    context.push(AppRouter.attendanceChild, extra: id);
  }
}
