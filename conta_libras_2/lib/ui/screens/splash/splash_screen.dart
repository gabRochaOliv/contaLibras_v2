import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/managers/user_manager.dart';
import '../../../data/services/profile_storage_service.dart';
import '../first_access/first_access_screen.dart';
import '../main/main_screen.dart';
import '../profile_selection/profile_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = ProfileStorageService();

  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    final activeIdFuture = _storage.getActiveProfileId();
    final profilesFuture = _storage.loadProfiles();
    final results = await Future.wait([
      activeIdFuture,
      profilesFuture,
      Future.delayed(const Duration(seconds: 3)),
    ]);
    if (!mounted) return;

    final activeId = results[0] as String?;
    final profiles = results[1] as List;

    Widget next;
    if (activeId != null) {
      final match = profiles.where((p) => p.id == activeId);
      if (match.isNotEmpty) {
        UserManager().loadFromProfile(match.first);
        next = const MainScreen();
      } else {
        next = profiles.isEmpty ? const FirstAccessScreen() : const ProfileSelectionScreen();
      }
    } else if (profiles.isNotEmpty) {
      next = const ProfileSelectionScreen();
    } else {
      next = const FirstAccessScreen();
    }

    if (!mounted) return;
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
