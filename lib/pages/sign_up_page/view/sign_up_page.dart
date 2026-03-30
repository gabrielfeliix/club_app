// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/sign_up_page/bloc/sign_up_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

//// quando digito primeiro o segundo campo de senha quando digito
//// a senha dps disso ele não atualiza so se apertar no o olho
//// mas ele atualiza quando digito um acrater a mais
//// dps q o cadastrar diz q ta com erro nada muda, ele não valida dnv
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SignUpBloc(authRepository: getIt<IAuthenticationRepository>()),
      child: SignUpPageView(),
    );
  }
}

// ignore: must_be_immutable
class SignUpPageView extends StatelessWidget {
  SignUpPageView({super.key});

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _passwordRepeatController =
      TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpBloc, SignUpState>(
      listener: _handlerListener,
      builder: _handlerBuilder,
    );
  }

  /// Dealing with bloc builder
  Widget _handlerBuilder(
    BuildContext context,
    SignUpState state,
  ) {
    final bloc = context.read<SignUpBloc>();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = bottomInset > 0;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: context.colors.onBackground,
        body: SafeArea(
          child: Padding(
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          height: isKeyboardOpen ? 60.h : 230.h,
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
                            'Cadastrar-se',
                            style: context.text.headlineMedium!.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ensine o caminho e eles nunca se desviarão!',
                            style: context.text.bodyMedium!
                                .copyWith(color: context.colors.surface),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        CustomTextField(
                          hint: 'Nome Completo',
                          textInputAction: TextInputAction.next,
                          textEditingController: _nameController,
                          autofillHints: const [AutofillHints.name],
                          validator: (vl) =>
                              state.fullName.validator(vl ?? '')?.text(),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField.email(
                          hint: 'Email',
                          textInputAction: TextInputAction.next,
                          textEditingController: _emailController,
                          validator: (vl) =>
                              state.email.validator(vl ?? '')?.text(),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField.password(
                          hint: 'Senha',
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                          obscure: state.obscure!,
                          textEditingController: _passwordController,
                          validator: (vl) =>
                              state.password.validator(vl ?? '')?.text(),
                          suffixIcon: IconButton(
                            onPressed: () => bloc.add(
                                const ChangeObscureRequired(firstObscure: true)),
                            icon: Icon(
                              state.obscure!
                                  ? IconsaxPlusLinear.eye_slash
                                  : IconsaxPlusLinear.eye,
                            ),
                            color: context.colors.primary,
                          ),
                          onChanged: (vl) {
                            bloc.add(
                              ChangePasswordAndConfirmPass(
                                password: vl,
                                confirmPassword: state.confirmedPassword.value,
                              ),
                            );
                          },
                        ),
                        _buildFeedbackValidator(
                          context,
                          state,
                          state.lowercase!,
                          'Letra minúscula',
                        ),
                        _buildFeedbackValidator(
                          context,
                          state,
                          state.uppercase!,
                          'Letra maiúscula',
                        ),
                        _buildFeedbackValidator(
                          context,
                          state,
                          state.atLeast8!,
                          'Pelo menos 8 caracteres',
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField.password(
                          hint: 'Digite a senha novamente',
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          obscure: state.secondObscure!,
                          textEditingController: _passwordRepeatController,
                          suffixIcon: IconButton(
                            onPressed: () =>
                                bloc.add(const ChangeObscureRequired()),
                            icon: Icon(
                              state.secondObscure!
                                  ? IconsaxPlusLinear.eye_slash
                                  : IconsaxPlusLinear.eye,
                              color: context.colors.primary,
                            ),
                          ),
                          validator: (vl) =>
                              state.confirmedPassword.validator(vl ?? '')?.text(),
                          onChanged: (vl) {
                            bloc.add(
                              ChangeConfirmPassRequired(
                                password: state.password.value,
                                confirmPassword: vl,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField.suffixIcon(
                          textEditingController: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.send,
                          validator: (vl) =>
                              state.phone.validator(vl ?? '')?.text(),
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: [MaskFormatter.phoneMaskFormatter],
                          hint: 'Telefone',
                          suffixIcon: Icon(
                            IconsaxPlusLinear.call,
                            color: context.colors.primary,
                          ),
                          onSubmitted: (st) {
                            if (st.isNotEmpty) {
                              if (_formKey.currentState!.validate()) {
                                bloc.add(
                                  SignUpRequired(
                                    phone: _phoneController.text,
                                    email: _emailController.text,
                                    username: _nameController.text,
                                    password: _passwordRepeatController.text,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        SizedBox(height: 20.h),
                        CustomButton(
                          label: 'Cadastrar',
                          isLoading: state.isLoading,
                          height: 35.h,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              bloc.add(
                                SignUpRequired(
                                  phone: _phoneController.text,
                                  email: _emailController.text,
                                  username: _nameController.text,
                                  password: _passwordRepeatController.text,
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 13.h),
                        Align(
                          alignment: Alignment.center,
                          child: _buildTextHiperLink(
                            context: context,
                            text: 'Já tem uma conta? ',
                            textLink: 'Entrar',
                            onTap: () => context.pop(),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget Section
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

  Widget _buildFeedbackValidator(
    BuildContext context,
    SignUpState state,
    bool validator,
    String desc,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w, top: 5.h),
      child: Row(
        children: [
          validator
              ? Icon(
                  IconsaxPlusLinear.tick_circle,
                  color: context.colors.primary,
                )
              : state.password.value.isEmpty
                  ? Icon(
                      IconsaxPlusLinear.tick_circle,
                      color: context.colors.surface,
                    )
                  : Icon(
                      IconsaxPlusLinear.tick_circle,
                      color: context.colors.error,
                    ),
          Text(
            ' $desc',
            style: context.text.bodyMedium!.copyWith(
              color: validator
                  ? context.colors.primary
                  : state.password.value.isEmpty
                      ? context.colors.surface
                      : context.colors.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Dealing with bloc listening
  _handlerListener(BuildContext context, SignUpState state) {
    if (state.isFailure) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.error,
      );
      FocusManager.instance.primaryFocus?.unfocus();
    }
    if (state.isSuccess) {
      showCustomSnackBar(
        context,
        state.message!,
        type: SnackBarType.success,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      context.pop();
    }
  }
}
