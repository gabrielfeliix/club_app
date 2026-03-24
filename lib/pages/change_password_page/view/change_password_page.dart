import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/main.dart'; // for getIt
import 'package:club_app/pages/change_password_page/bloc/change_password_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordBloc(
        authRepository: getIt<IAuthenticationRepository>(),
      ),
      child: const ChangePasswordView(),
    );
  }
}

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Senha'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            showCustomSnackBar(
              context,
              state.errorMessage ?? 'Erro ao atualizar senha',
              type: SnackBarType.error,
            );
          } else if (state.status.isSuccess) {
            showCustomSnackBar(
              context,
              'Senha atualizada com sucesso!',
              type: SnackBarType.success,
            );
            context.pop();
          }
        },
        builder: (context, state) {
          final bloc = context.read<ChangePasswordBloc>();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField.password(
                    hint: 'Nova senha',
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    textInputAction: TextInputAction.next,
                    obscure: state.obscure,
                    textEditingController: _passwordController,
                    validator: (vl) =>
                        state.password.validator(vl ?? '')?.text(),
                    suffixIcon: IconButton(
                      onPressed: () => bloc.add(ChangePasswordObscureToggled()),
                      icon: Icon(
                        state.obscure
                            ? Icons.visibility_off
                            : Icons.remove_red_eye,
                      ),
                      color: context.colors.primary,
                    ),
                    onChanged: (vl) {
                      bloc.add(
                        ChangePasswordChanged(
                          vl,
                          state.confirmedPassword.value,
                        ),
                      );
                    },
                  ),
                  _buildFeedbackValidator(context, state.lowercase, 'Letra minúscula'),
                  _buildFeedbackValidator(context, state.uppercase, 'Letra maiúscula'),
                  _buildFeedbackValidator(context, state.atLeast8, 'Pelo menos 8 caracteres'),
                  const SizedBox(height: 20),
                  CustomTextField.password(
                    hint: 'Confirme a nova senha',
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (_formKey.currentState!.validate()) {
                        bloc.add(ChangePasswordSubmitted());
                      }
                    },
                    obscure: state.secondObscure,
                    textEditingController: _passwordRepeatController,
                    suffixIcon: IconButton(
                      onPressed: () => bloc.add(ChangePasswordSecondObscureToggled()),
                      icon: Icon(
                        state.secondObscure
                            ? Icons.visibility_off
                            : Icons.remove_red_eye,
                        color: context.colors.primary,
                      ),
                    ),
                    validator: (vl) =>
                        state.confirmedPassword.validator(vl ?? '')?.text(),
                    onChanged: (vl) {
                      bloc.add(
                        ChangePasswordConfirmChanged(
                          state.password.value,
                          vl,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'Salvar Nova Senha',
                    height: 45,
                    isLoading: state.status.isInProgress,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        bloc.add(ChangePasswordSubmitted());
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackValidator(
    BuildContext context,
    bool validator,
    String desc,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: validator
                ? context.colors.primary
                : context.colors.onSurfaceVariant.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            desc,
            style: context.text.bodyMedium!.copyWith(
              color: validator
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
