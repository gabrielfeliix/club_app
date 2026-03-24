// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/pages/clubs_page/bloc/clubs_bloc.dart';
import 'package:club_app/routes/routes.dart';
import 'package:club_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

//? TO DO
//? novo layout de clubinhos ( ideias no WHATSAPP )
//? Loading Shimmer
//? Responsive layout
////? Apos definir o design e a cor de fundo ver a questão do estilo do Nenhum Clubinho Vinculado
//// Regex pra mais de um espaço
//// Imagem legal quando estiver sem clubinho
//// quando o textfield do criar/entrar num clubinho da erro ele nao tira o erro quando digita
//! quando um clubinho é deletado e voltamos pra tela de clubinhos ele nao some
//// qu8ando entrar em um clubinho o feedback ta funcionando direito?

// ignore: must_be_immutable
class ClubsPageView extends StatelessWidget {
  ClubsPageView({super.key});

  bool isAdmin = false;

  @override
  Widget build(BuildContext context) {
    final authUser =
        CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
    isAdmin = authUser?.userRole == UserRole.admin;
    return BlocConsumer<ClubsBloc, ClubsBlocState>(
      listener: _handlerListener,
      builder: _handlerBuilder,
    );
  }

  /// Dealing with bloc builder
  Widget _handlerBuilder(
    BuildContext context,
    ClubsBlocState state,
  ) {
    if (state.clubs != null) {
      return Scaffold(
        floatingActionButton: _buildFloatingActionButton(context),
        body: RefreshIndicator(
          onRefresh: () => _refreshClubs(context),
          child: ListView.builder(
            itemCount: state.clubs!.length,
            itemBuilder: (context, index) {
              return _buildRoundedSquare(
                context,
                state.clubs![index].name,
                state.clubs![index].id,
              );
            },
          ),
        ),
      );
    } else if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        floatingActionButton: _buildFloatingActionButton(context),
        body: RefreshIndicator(
          onRefresh: () => _refreshClubs(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 350.w),
                            child: Padding(
                              padding: EdgeInsets.all(40.sp),
                              child: Image.asset(
                                ImageConstant.iconEmpty,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const Text('Nenhum Clubinho Vinculado!'),
                          SizedBox(height: 70.h),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  /// Section Widget
  _buildAlertDialog(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required bool event,
  }) {
    final bloc = context.read<ClubsBloc>();

    final TextEditingController nameController = TextEditingController();

    final TextEditingController addressController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: bloc,
          child: BlocConsumer<ClubsBloc, ClubsBlocState>(
            listener: _handlerListenerDialog,
            builder: (context, state) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.center,
                backgroundColor: context.theme.colorScheme.onPrimary,
                title: Text(
                  title,
                  style: context.text.headlineMedium?.copyWith(
                    color: context.colors.onSecondary,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(
                    color: context.colors.surface,
                    width: 2.w,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          // height: 40.h,
                          child: CustomTextField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            hint: 'Nome',
                            textInputAction: TextInputAction.next,
                            textEditingController: nameController,
                            validator: (vl) =>
                                state.name.validator(vl ?? '')?.text(),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          child: CustomTextField(
                            hint: 'Endereço',
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            maxLines: 3,
                            textInputAction: TextInputAction.next,
                            textEditingController: addressController,
                            validator: (vl) =>
                                state.address.validator(vl ?? '')?.text(),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        if (state.isLoading)
                          LoadingAnimationWidget.waveDots(
                            color: context.colors.primary,
                            size: 30.sp,
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 245.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CustomButton.pop(
                            label: 'Voltar',
                            isLoading: false,
                            height: 35.h,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomButton(
                            label: actionLabel,
                            isLoading: false,
                            height: 35.h,
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                context.read<ClubsBloc>().add(
                                      AddClubRequired(
                                        name: nameController.text,
                                        address: addressController.text,
                                      ),
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildRoundedSquare(BuildContext context, String name, String id) {
    return Padding(
      padding:
          EdgeInsets.only(right: 30.w, left: 30.w, top: 10.h, bottom: 10.h),
      child: LayoutBuilder(builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 155.w),
          child: SizedBox(
            height: 150.h,
            child: ElevatedButton(
              onPressed: () => onTapManageClub(context, id),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.onPrimary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.onSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 8),
                      child: Image.asset(
                        'assets/icons/wired-outline-1531-rocking-horse-hover-pinch.png',
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8, right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Transform.rotate(
                        angle: 10.2,
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: context.colors.onSecondary,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Section Widget
  Widget? _buildFloatingActionButton(BuildContext context) {
    return isAdmin
        ? FloatingActionButton(
            backgroundColor: context.colors.primary,
            shape: const CircleBorder(),
            onPressed: () => _buildAlertDialog(
              context,
              title: 'Novo Clubinho Bíblico',
              actionLabel: 'Criar',
              event: false,
            ),
            child: Icon(Icons.add, color: context.colors.onPrimary),
          )
        : null;
  }

  /// Dealing with bloc listening
  _handlerListener(BuildContext context, ClubsBlocState state) {
    if (state.isFailure) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.error,
      );
    } else if (state.isLoading) {
      // showCustomSnackBar(
      //   context,
      //   'Carregado!',
      //   type: SnackBarType.success,
      // );
    } else if (state.isCreated) {
      context.read<ClubsBloc>().add(GetClubsRequired());
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.success,
      );
    } else if (state.isSuccess) {
      context.read<ClubsBloc>().add(GetClubsRequired());
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.success,
      );
    }
  }

  /// Dealing with bloc listening
  _handlerListenerDialog(BuildContext context, ClubsBlocState state) {
    if (state.isFailure) {
      Navigator.of(context).pop();
    } else if (state.isLoading) {
      FocusManager.instance.primaryFocus?.unfocus();
    } else if (state.isCreated) {
      context.read<ClubsBloc>().add(GetClubsRequired());
      Navigator.of(context).pop();
    } else if (state.isSuccess) {
      context.read<ClubsBloc>().add(GetClubsRequired());
      Navigator.of(context).pop();
      // _clearTextFields();
    }
  }

  /// Navigates to the manage club when the action is triggered.
  onTapManageClub(BuildContext context, String id) {
    context.push(AppRouter.manageClub, extra: id);
  }

  /// Refreshes the list of clubs.
  Future<void> _refreshClubs(BuildContext context) async {
    context.read<ClubsBloc>().add(GetClubsRequired());
  }
}
