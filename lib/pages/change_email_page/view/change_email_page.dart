import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/main.dart'; // for getIt
import 'package:club_app/pages/change_email_page/bloc/change_email_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

class ChangeEmailPage extends StatelessWidget {
  const ChangeEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangeEmailBloc(
        authRepository: getIt<IAuthenticationRepository>(),
      ),
      child: const ChangeEmailView(),
    );
  }
}

class ChangeEmailView extends StatefulWidget {
  const ChangeEmailView({super.key});

  @override
  State<ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar E-mail'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocConsumer<ChangeEmailBloc, ChangeEmailState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            showCustomSnackBar(
              context,
              state.errorMessage ?? 'Erro ao atualizar e-mail',
              type: SnackBarType.error,
            );
          } else if (state.status.isSuccess) {
            showCustomSnackBar(
              context,
              'Instruções enviadas! Verifique seu novo e-mail.',
              type: SnackBarType.success,
            );
            context.pop();
          }
        },
        builder: (context, state) {
          final bloc = context.read<ChangeEmailBloc>();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField.email(
                    hint: 'Novo E-mail',
                    textInputAction: TextInputAction.done,
                    textEditingController: _emailController,
                    validator: (vl) => state.email.validator(vl ?? '')?.text(),
                    onChanged: (vl) => bloc.add(ChangeEmailChanged(vl)),
                    onSubmitted: (_) {
                      if (_formKey.currentState!.validate()) {
                        bloc.add(ChangeEmailSubmitted());
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'Solicitar Alteração',
                    height: 45,
                    isLoading: state.status.isInProgress,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        bloc.add(ChangeEmailSubmitted());
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Poderá ser necessário confirmar a alteração em ambas as caixas de entrada para finalizar o processo de segurança.',
                    style: context.text.bodySmall!
                        .copyWith(color: context.colors.onSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
