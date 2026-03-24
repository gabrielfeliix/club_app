import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/main.dart';
import 'package:club_app/pages/edit_profile_page/bloc/edit_profile_bloc.dart';
import 'package:club_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialPhone,
  });

  final String initialName;
  final String initialPhone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc(
        authRepository: getIt<IAuthenticationRepository>(),
        initialName: initialName,
        initialPhone: initialPhone,
      ),
      child: EditProfileView(
        initialName: initialName,
        initialPhone: initialPhone,
      ),
    );
  }
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({
    super.key,
    required this.initialName,
    required this.initialPhone,
  });

  final String initialName;
  final String initialPhone;

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocListener<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            showCustomSnackBar(
              context,
              state.errorMessage ?? 'Erro ao atualizar perfil',
              type: SnackBarType.error,
            );
          } else if (state.status.isSuccess) {
            showCustomSnackBar(
              context,
              'Perfil atualizado com sucesso!',
              type: SnackBarType.success,
            );
            context.pop(true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<EditProfileBloc, EditProfileState>(
                  buildWhen: (previous, current) => previous.name != current.name,
                  builder: (context, state) {
                    return CustomTextField(
                      hint: 'Nome Completo',
                      textInputAction: TextInputAction.next,
                      textEditingController: _nameController,
                      autofillHints: const [AutofillHints.name],
                      validator: (vl) =>
                          state.name.validator(vl ?? '')?.text(),
                      onChanged: (vl) => context
                          .read<EditProfileBloc>()
                          .add(EditProfileNameChanged(vl)),
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<EditProfileBloc, EditProfileState>(
                  buildWhen: (previous, current) => previous.phone != current.phone,
                  builder: (context, state) {
                    return CustomTextField.suffixIcon(
                      hint: 'Telefone',
                      textEditingController: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [MaskFormatter.phoneMaskFormatter],
                      suffixIcon: Icon(Icons.phone_outlined, color: context.colors.primary),
                      validator: (vl) =>
                          state.phone.validator(vl ?? '')?.text(),
                      onChanged: (vl) => context
                          .read<EditProfileBloc>()
                          .add(EditProfilePhoneChanged(vl)),
                    );
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<EditProfileBloc, EditProfileState>(
                  builder: (context, state) {
                    return CustomButton(
                      label: 'Salvar Alterações',
                      height: 45,
                      isLoading: state.status.isInProgress,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final authUser = CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);
                          if (authUser != null) {
                            context
                                .read<EditProfileBloc>()
                                .add(EditProfileSubmitted(userId: authUser.userId));
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
