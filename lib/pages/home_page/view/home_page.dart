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
import 'package:club_app/pages/general_reports_page/bloc/general_reports_bloc.dart';
import 'package:club_app/pages/general_reports_page/view/general_reports_view.dart';
import 'package:club_app/pages/notifications/bloc/notifications_bloc.dart';
import 'package:club_app/utils/constants.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:club_repository/club_repository.dart';
import 'package:attendance_repository/attendance_repository.dart';
import 'package:decision_repository/decision_repository.dart';
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
            final authUser =
                CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
            return AccountBloc(
              authRepository: getIt<IAuthenticationRepository>(),
              clubRepository: getIt<IClubRepository>(),
            )..add(GetAccountDataRequired(userId: authUser?.userId ?? ''));
          },
        ),
        BlocProvider(
          create: (_) => GeneralReportsBloc(
            clubRepository: getIt<IClubRepository>(),
            attendanceRepository: getIt<IAttendanceRepository>(),
            decisionRepository: getIt<IDecisionRepository>(),
          )..add(LoadGeneralReportsRequired()),
        ),
        BlocProvider(
          create: (_) => NotificationsBloc(
            notificationRepository: getIt<INotificationRepository>(),
          )..add(GetNotifications()),
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
              const GeneralReportsView(),
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
              'Clubinho\nBíblico',
              style: context.text.titleLarge?.copyWith(fontSize: 13.sp),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () => _showNotificationsBottomSheet(context),
                icon: Badge(
                  label: Text(state.unreadCount.toString()),
                  isLabelVisible: state.unreadCount > 0,
                  backgroundColor: context.colors.error,
                  child: const Icon(Icons.notifications),
                ),
                color: context.colors.onPrimary,
              );
            },
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
            text: 'Estatísticas',
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

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<NotificationsBloc>(),
          child: const NotificationsBottomSheet(),
        );
      },
    );
  }
}

class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 600.h,
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notificações',
                  style: context.text.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    context.read<NotificationsBloc>().add(MarkAllAsRead());
                  },
                  child: const Text('Limpar Tudo'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64.sp,
                            color: context.colors.outline,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Nenhuma notificação por enquanto.',
                            style: context.text.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NotificationsBloc>().add(GetNotifications());
                    },
                    child: ListView.builder(
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return ListTile(
                          leading: Badge(
                            isLabelVisible: !notification.isRead,
                            child: Icon(
                              Icons.message,
                              color: context.colors.primary,
                            ),
                          ),
                          title: Text(
                            notification.title,
                            style: context.text.titleMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification.message),
                              SizedBox(height: 5.h),
                              Text(
                                '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}',
                                style: context.text.labelSmall?.copyWith(
                                  color: context.colors.outline,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            context
                                .read<NotificationsBloc>()
                                .add(MarkAsRead(id: notification.id));
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
      ),
    );
  }
}
