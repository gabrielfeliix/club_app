// ignore_for_file: deprecated_member_use

import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/clubs_page/bloc/clubs_bloc.dart';
import 'package:club_app/pages/clubs_page/view/clubs_page.dart';
import 'package:club_app/pages/sign_in_page/bloc/authentication_bloc.dart';
import 'package:club_app/pages/users_manage/bloc/users_manage_bloc.dart';
import 'package:club_app/pages/users_manage/view/users_manage_page.dart';
import 'package:club_app/pages/account_page/view/account_page.dart';
import 'package:club_app/pages/account_page/bloc/account_bloc.dart';
import 'package:club_app/routes/routes.dart';
import 'package:club_app/utils/constants.dart';
import 'package:club_repository/club_repository.dart';
import 'package:flutter/material.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthenticationBloc(
            authRepository: getIt<IAuthenticationRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => ClubsBloc(
            clubRepository: getIt<IClubRepository>(),
          )..add(GetClubsRequired()),
        ),
        BlocProvider(
          create: (_) => UsersManageBloc(
            authenticationRepository: getIt<IAuthenticationRepository>(),
          )..add(GetAllUsersRequired()),
        ),
        BlocProvider(
          create: (_) {
            final authUser = CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
            return AccountBloc(
              authRepository: getIt<IAuthenticationRepository>(),
              clubRepository: getIt<IClubRepository>(),
            )..add(GetAccountDataRequired(userId: authUser?.userId ?? ''));
          },
        ),
      ],
      child: const HomeScreenView(),
    );
  }
}

//? TO DO
//! se eu der dps alguem como admin ele não recebe acesso a todos os outros clubinhos
//! ( outras trocas de role tbm ver os clubs q ficam na conta)
class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser =
        CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
    final bool isAdmin = authUser?.userRole == UserRole.admin;
    final int tabCount = isAdmin ? 4 : 3;
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: _onAuthStateChanged,
      child: DefaultTabController(
        length: tabCount,
        child: Scaffold(
          appBar: _buildAppBar(context, isAdmin),
          body: TabBarView(
            children: [
              Container(color: Colors.blue),
              ClubsPageView(),
              if (isAdmin) const UsersManageView(),
              const AccountView(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isAdmin) {
    return AppBar(
      toolbarHeight: 50.h,
      leadingWidth: 220.w,
      leading: Row(
        children: [
          Image.asset(
            height: 45.h,
            ImageConstant.logoIbavin,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
          ),
          Flexible(
            child: Text(
              'IGREJA BATISTA\nVIDA NOVA',
              style: context.text.titleLarge,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
            color: context.colors.onPrimary,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 25.w),
          child: IconButton(
            onPressed: () =>
                context.read<AuthenticationBloc>().add(SignOutRequired()),
            icon: const Icon(Icons.login_outlined),
            color: context.colors.onPrimary,
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: context.colors.primary,
      bottom: TabBar(
        isScrollable: true,
        unselectedLabelStyle: context.text.labelSmall!.copyWith(
          color: context.colors.onPrimary.withOpacity(0.6),
        ),
        labelStyle: context.text.labelSmall!.copyWith(
          color: context.colors.onPrimary,
        ),
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.center,
        tabs: [
          const Tab(
            text: 'Estatisticas Gerais',
          ),
          const Tab(
            text: 'Clubinhos',
          ),
          if (isAdmin)
            const Tab(
              text: 'Usuários',
            ),
          const Tab(
            text: 'Conta',
          ),
        ],
      ),
    );
  }

  /// Dealing with bloc listening
  _onAuthStateChanged(BuildContext context, AuthenticationState state) {
    if (state.isCanceled) {
      onTapSignOut(context);
    }
  }

  /// Navigates to the SignIn screen when SignOut is performed.
  void onTapSignOut(BuildContext context) {
    context.go(AppRouter.signInScreen);
  }
}
