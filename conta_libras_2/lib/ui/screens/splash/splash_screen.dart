import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/managers/user_manager.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/profile_storage_service.dart';
import '../first_access/first_access_screen.dart';
import '../main/main_screen.dart';
import '../profile_selection/profile_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashState {
  const _SplashState(this.activeId, this.profiles);

  final String? activeId;
  final List<UserProfile> profiles;
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = ProfileStorageService();

  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<_SplashState> _loadState() async {
    try {
      final activeId = await _storage.getActiveProfileId();
      final profiles = await _storage.loadProfiles();
      return _SplashState(activeId, profiles);
    } catch (_) {
      // Se o armazenamento local falhar por qualquer motivo, segue para o
      // cadastro em vez de deixar a splash girando para sempre.
      return const _SplashState(null, []);
    }
  }

  Future<void> _decideNextScreen() async {
    final results = await Future.wait<Object?>([
      _loadState(),
      Future<void>.delayed(const Duration(seconds: 3)),
    ]);
    if (!mounted) return;

    final state = results[0] as _SplashState;

    Widget next = const FirstAccessScreen();
    if (state.activeId != null) {
      final match = state.profiles.where((p) => p.id == state.activeId);
      if (match.isNotEmpty) {
        UserManager().loadFromProfile(match.first);
        next = const MainScreen();
      } else if (state.profiles.isNotEmpty) {
        next = const ProfileSelectionScreen();
      }
    } else if (state.profiles.isNotEmpty) {
      next = const ProfileSelectionScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.asset(
                'assets/images/logoContaLibras.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 64),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
