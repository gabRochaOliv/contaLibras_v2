import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/managers/user_manager.dart';
import '../../../data/managers/theme_manager.dart';
import '../../../data/services/profile_storage_service.dart';
import '../profile_selection/profile_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            child: const Text('Sair', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ProfileStorageService().clearActiveProfileId();
    UserManager().clear();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
      (route) => false,
    );
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
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
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
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                    secondary: Icon(
                      Icons.dark_mode_rounded, 
                      color: ThemeManager().isDarkMode ? Colors.white : AppColors.primary
                    ),
                    value: ThemeManager().isDarkMode,
                    onChanged: (value) {
                      ThemeManager().toggleTheme();
                    },
                    activeColor: AppColors.primary,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.settings_rounded, 
                  color: ThemeManager().isDarkMode ? Colors.white : AppColors.primary
                ),
                title: Text('Configurações', style: AppTextStyles.bodyLarge),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.info_outline_rounded, 
                  color: ThemeManager().isDarkMode ? Colors.white : AppColors.primary
                ),
                title: Text('Sobre o App', style: AppTextStyles.bodyLarge),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.accent),
                title: Text(
                  'Sair',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.accent),
                ),
                onTap: () => _logout(context),
              ),
        ],
      ),
    ),
    ),
    );
  }
}
