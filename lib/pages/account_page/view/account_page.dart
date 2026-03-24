import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/routes/routes.dart';
import 'package:club_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:club_app/pages/account_page/bloc/account_bloc.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    // Buscar usuário logado do cache local
    final authUser =
        CacheClient.read<AuthUserModel>(key: AppConstants.userCacheKey);

    if (authUser == null) {
      return const Center(child: Text('Nenhum dado de conta disponível.'));
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state.isLoading || state.isInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isFailure || state.user == null) {
            return Center(
                child:
                    Text(state.message ?? 'Erro ao carregar dados da conta.'));
          }

          final currentUser = state.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            context.colors.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: context.colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentUser.name.isNotEmpty
                            ? currentUser.name
                            : 'Desconhecido',
                        style: context.text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleLabel(authUser.userRole),
                          style: context.text.labelLarge?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Profile Information Cards
                _buildInfoCard(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: currentUser.email,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Telefone',
                  value: currentUser.contact,
                ),

                const SizedBox(height: 24),

                // Clubs Section
                if (state.clubs != null && state.clubs!.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Meus Clubinhos',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...state.clubs!.map((club) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.primary.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.onSurface.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.maps_home_work_outlined,
                                color: context.colors.primary, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              club.name,
                              style: context.text.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ] else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Meus Clubinhos',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.colors.onSurface.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      'Nenhum clubinho vinculado.',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Future actions (like Edit Profile, change password, etc)
                _buildActionCard(
                  context,
                  icon: Icons.edit_outlined,
                  title: 'Editar Perfil',
                  onTap: () async {
                    final shouldRefresh = await context.push<bool>(
                      AppRouter.editProfile,
                      extra: {
                        'name': state.user?.name ?? '',
                        'phone': state.user?.contact ?? '',
                      },
                    );
                    if (shouldRefresh == true) {
                      final userId = state.user?.id;
                      if (userId != null) {
                        context.read<AccountBloc>().add(GetAccountDataRequired(userId: userId));
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  context,
                  icon: Icons.password_outlined,
                  title: 'Alterar Senha',
                  onTap: () {
                    context.push(AppRouter.changePassword);
                  },
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  context,
                  icon: Icons.alternate_email_outlined,
                  title: 'Alterar E-mail',
                  onTap: () {
                    context.push(AppRouter.changeEmail);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.primary.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.colors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: context.text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context
            .theme.colorScheme.onPrimary, // Usually white or surface color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.colors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Não informado',
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors
                        .onSurface, // User requested dark/black text via theme
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'Professor';
      case UserRole.coordinator:
        return 'Coordenador';
      case UserRole.admin:
        return 'Administrador';
    }
  }
}
