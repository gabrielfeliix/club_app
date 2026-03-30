// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/sign_in_page/bloc/authentication_bloc.dart';
import 'package:club_app/routes/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

//? TO DO
//? só permitir o login com o email verificado
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc(
        authRepository: getIt<IAuthenticationRepository>(),
      ),
      child: SignInPageView(),
    );
  }
}

class SignInPageView extends StatelessWidget {
  SignInPageView({super.key});

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: _handlerListener,
      builder: _handlerBuilder,
    );
  }

  /// Dealing with bloc builder
  Widget _handlerBuilder(
    BuildContext context,
    AuthenticationState state,
  ) {
    final bloc = context.read<AuthenticationBloc>();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = bottomInset > 0;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: context.colors.onBackground,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 35.w),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 245.h),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        height: isKeyboardOpen ? 80.h : 230.h,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 5.h),
                          child: Hero(
                            tag: ImageConstant.logoClub,
                            child: Image.asset(
                              ImageConstant.logoClub,
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Entrar',
                          style: context.text.headlineMedium!.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ganhe corações para Jesus desde a infância!',
                          style: context.text.bodyMedium!
                              .copyWith(color: context.colors.surface),
                        ),
                      ),
                      SizedBox(height: 17.h),
                      CustomTextField.email(
                        hint: 'Email',
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.disabled,
                        textEditingController: _emailController,
                        validator: (value) =>
                            state.email.validator(value ?? '')?.text(),
                      ),
                      SizedBox(height: 13.h),
                      CustomTextField.password(
                        obscure: state.obscure,
                        textInputAction: TextInputAction.send,
                        autovalidateMode: AutovalidateMode.disabled,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite uma senha';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () =>
                              bloc.add(ChangeObscureRequired()),
                          icon: Icon(
                            state.obscure!
                                ? IconsaxPlusLinear.eye_slash
                                : IconsaxPlusLinear.eye,
                          ),
                          color: context.colors.primary,
                        ),
                        hint: 'Senha',
                        textEditingController: _passwordController,
                        onSubmitted: (st) => st.isNotEmpty
                            ? bloc.add(
                                SignInRequired(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              )
                            : {},
                      ),
                      SizedBox(height: 13.h),
                      Align(
                        alignment: Alignment.topLeft,
                        child: _buildTextHiperLink(
                          context: context,
                          text: 'Esqueceu a senha?',
                          textLink: 'Clique aqui',
                          onTap: () {},
                        ),
                      ),
                      SizedBox(height: 50.h),
                      CustomButton(
                        label: 'Entrar',
                        isLoading: state.isProgress,
                        height: 35.h,
                        onPressed: () {
                          _formKey.currentState!.validate()
                              ? bloc.add(
                                  SignInRequired(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                )
                              : null;
                        },
                      ),
                      SizedBox(height: 13.h),
                      Align(
                        alignment: Alignment.center,
                        child: _buildTextHiperLink(
                          context: context,
                          text: 'Não tem uma conta? ',
                          textLink: 'Cadastre-se',
                          onTap: () => onTapSignUp(context),
                        ),
                      ),
                      SizedBox(height: 13.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Dealing with bloc listening
  _handlerListener(BuildContext context, AuthenticationState state) {
    if (state.isFailure) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.error,
      );
    }
    if (state.isSuccess) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.success,
      );
      onTapLogin(context);
    }
  }

  ///Section Widget
  Widget _buildTextHiperLink({
    required BuildContext context,
    required String text,
    required String textLink,
    required GestureTapCallback onTap,
  }) {
    return RichText(
      text: TextSpan(
        style: context.text.bodySmall!
            .copyWith(color: context.colors.onSecondary.withOpacity(0.5)),
        children: <TextSpan>[
          TextSpan(
            text: ' $text',
          ),
          TextSpan(
            text: ' $textLink',
            style: context.text.labelLarge!
                .copyWith(color: context.colors.primary),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }

  /// Navigates to the home screen when login is performed.
  onTapLogin(BuildContext context) {
    context.go(AppRouter.homeScreen);
  }

  /// Navigates to the Sign Up screen when login is performed.
  void onTapSignUp(BuildContext context) {
    context.push(AppRouter.signUpScreen);
  }
}
