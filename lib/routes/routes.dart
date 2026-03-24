import 'package:club_app/pages/attendance_page/view/attendance_page.dart';
import 'package:club_app/pages/attendance_page/view/take_attendance_page.dart';
import 'package:club_app/pages/reports_page/view/reports_page.dart';
import 'package:club_app/pages/detail_page/detail_page.dart';
import 'package:club_app/pages/manage_club_page/view/manage_club_page.dart';
import 'package:club_app/pages/child_registration_page/view/child_registration_page.dart';
import 'package:club_app/pages/users_manage/view/users_manage_page.dart';
import 'package:club_app/utils/helpers.dart';
import 'package:club_repository/club_repository.dart';
import 'package:attendance_repository/attendance_repository.dart' hide KidsModel;
import 'package:go_router/go_router.dart';
import 'package:club_app/pages/home_page/view/home_page.dart';
import 'package:club_app/pages/manage_member_page/view/manage_member_page.dart';
import 'package:club_app/pages/sign_in_page/view/sign_in_page.dart';
import 'package:club_app/pages/sign_up_page/view/sign_up_page.dart';
import 'package:club_app/pages/verification_code_page/verification_code_page.dart';
import 'package:club_app/pages/edit_profile_page/view/edit_profile_page.dart';
import 'package:club_app/pages/change_password_page/view/change_password_page.dart';
import 'package:club_app/pages/change_email_page/view/change_email_page.dart';
import 'package:club_app/pages/decisions_page/view/decisions_page.dart';
import 'package:club_app/pages/decisions_page/view/add_decision_page.dart';
import 'package:club_app/pages/schedules_page/view/schedules_page.dart';
import 'package:club_app/pages/schedules_page/view/schedule_form_page.dart';
import 'package:club_app/pages/schedules_page/view/schedule_view_page.dart';
import 'package:schedule_repository/schedule_repository.dart';

class AppRouter {
  static const String signInScreen = '/';

  static const String signUpScreen = '/sign_up';

  static const String homeScreen = '/home';

  static const String manageClub = '/manage_club';

  static const String manageMembers = '/manage_Users';

  static const String manageChildren = '/manage_children';

  static const String childRegistration = '/child_registration';

  static const String userInformation = '/user_information';

  static const String childInformation = '/child_information';

  static const String attendanceChild = '/child_attendance';

  static const String takeAttendance = '/take_attendance';

  static const String reports = '/reports';

  static const String codeVerification = '/code_verification';

  static const String usersManage = '/users_manage';

  static const String editProfile = '/edit_profile';
  static const String changePassword = '/change_password';
  static const String changeEmail = '/change_email';
  static const String decisions = '/decisions';
  static const String addDecision = '/add_decision';
  static const String schedules = '/schedules';
  static const String scheduleForm = '/schedule_form';
  static const String scheduleView = '/schedule_view';

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: AppRouter.signInScreen,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRouter.signUpScreen,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRouter.editProfile,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return EditProfilePage(
            initialName: extra['name'] as String? ?? '',
            initialPhone: extra['phone'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRouter.homeScreen,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRouter.manageClub,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (club) => ManageClubPage(id: club),
        ),
      ),
      GoRoute(
        path: AppRouter.manageMembers,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (club) => ManageMemberPage.teachers(id: club),
        ),
      ),
      GoRoute(
        path: AppRouter.manageChildren,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (club) => ManageMemberPage.children(id: club),
        ),
      ),
      GoRoute(
        path: AppRouter.childRegistration,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (club) => ChildRegistrationPage(id: club),
        ),
      ),
      GoRoute(
        path: AppRouter.userInformation,
        builder: (context, state) => Helpers.openPage<TeachersModel>(
          context,
          state,
          (user) => DetailPage.teacher(teacher: user),
        ),
      ),
      GoRoute(
        path: AppRouter.childInformation,
        builder: (context, state) => Helpers.openPage<KidsModel>(
          context,
          state,
          (user) => DetailPage.kid(kid: user),
        ),
      ),
      GoRoute(
        path: AppRouter.codeVerification,
        builder: (context, state) => const VerificationCode(),
      ),
      GoRoute(
        path: AppRouter.attendanceChild,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (club) => AttendancePage(id: club),
        ),
      ),
      GoRoute(
        path: AppRouter.takeAttendance,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return TakeAttendancePage(
              id: extra['clubId'] as String,
              attendanceModel: extra['attendanceModel'] as AttendanceModel?,
            );
          } else {
            return TakeAttendancePage(id: extra as String);
          }
        },
      ),
      GoRoute(
        path: AppRouter.reports,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (clubId) => ReportsPage(id: clubId),
        ),
      ),
      GoRoute(
        path: AppRouter.usersManage,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (clubId) => const UsersManageView(),
        ),
      ),
      GoRoute(
        path: AppRouter.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: AppRouter.changeEmail,
        builder: (context, state) => const ChangeEmailPage(),
      ),
      GoRoute(
        path: AppRouter.decisions,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (clubId) => DecisionsPage(id: clubId),
        ),
      ),
      GoRoute(
        path: '${AppRouter.addDecision}/:id',
        builder: (context, state) {
          final clubId = state.pathParameters['id']!;
          return AddDecisionPage(clubId: clubId);
        },
      ),
      GoRoute(
        path: AppRouter.schedules,
        builder: (context, state) => Helpers.openPage<String>(
          context,
          state,
          (clubId) => SchedulesPage(clubId: clubId),
        ),
      ),
      GoRoute(
        path: AppRouter.scheduleForm,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ScheduleFormPage(
            clubId: extra['clubId'] as String,
            schedule: extra['schedule'] as ScheduleModel?,
          );
        },
      ),
      GoRoute(
        path: AppRouter.scheduleView,
        builder: (context, state) {
          final schedule = state.extra as ScheduleModel;
          return ScheduleViewPage(schedule: schedule);
        },
      ),
    ],
  );
}
