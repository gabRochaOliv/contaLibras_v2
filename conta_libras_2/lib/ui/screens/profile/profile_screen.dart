import 'package:flutter/material.dart';
import '../../widgets/developer_footer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/managers/progress_manager.dart';
import '../../../data/managers/user_manager.dart';
import '../../../data/managers/theme_manager.dart';
import '../../../data/services/profile_storage_service.dart';
import '../about/about_screen.dart';
import '../profile_selection/profile_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onOpenAbout});

  /// Abre o "Sobre o App" dentro da MainScreen (mantendo a navegação).
  /// Sem ele, a tela é empilhada no Navigator.
  final VoidCallback? onOpenAbout;

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text(
          'Deseja sair deste perfil? Seus dados continuam salvos neste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sair', style: TextStyle(color: AppColors.accentFg)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    UserManager().clear();
    ProgressManager().clear();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
      (route) => false,
    );

    try {
      await ProfileStorageService().clearActiveProfileId();
    } catch (_) {
      // Sessão local já foi encerrada mesmo que a persistência falhe.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Image.asset('assets/images/logoContaLibras.png', height: 60),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              AnimatedBuilder(
                animation: UserManager(),
                builder: (context, child) {
                  final user = UserManager();
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.action,
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.userName,
                        style: AppTextStyles.heading2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.userCategory,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: ThemeManager(),
                builder: (context, child) {
                  return SwitchListTile(
                    title: Text('Modo Escuro', style: AppTextStyles.bodyLarge),
                    secondary: Icon(Icons.dark_mode_rounded,
                        color: AppColors.primaryFg),
                    value: ThemeManager().isDarkMode,
                    onChanged: (value) {
                      ThemeManager().toggleTheme();
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.info_outline_rounded,
                    color: AppColors.primaryFg),
                title: Text('Sobre o App', style: AppTextStyles.bodyLarge),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
                onTap: onOpenAbout ??
                    () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AboutScreen()),
                        ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout_rounded, color: AppColors.accentFg),
                title: Text(
                  'Sair',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.accentFg),
                ),
                onTap: () => _logout(context),
              ),
              const DeveloperFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
