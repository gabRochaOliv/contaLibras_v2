import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class ProfileStorageService {
  static const _profilesKey = 'contalibras_profiles';
  static const _activeProfileIdKey = 'contalibras_active_profile_id';
  static const _timeout = Duration(seconds: 4);

  Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance().timeout(_timeout);
  }

  Future<List<UserProfile>> loadProfiles() async {
    try {
      final prefs = await _prefs();
      final raw = prefs.getStringList(_profilesKey) ?? [];
      return raw
          .map((item) => UserProfile.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ProfileStorage] falha ao carregar perfis: $e');
      return [];
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await _prefs();
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await prefs.setStringList(
      _profilesKey,
      profiles.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  Future<void> deleteProfile(String id) async {
    final prefs = await _prefs();
    final profiles = await loadProfiles();
    profiles.removeWhere((p) => p.id == id);
    await prefs.setStringList(
      _profilesKey,
      profiles.map((p) => jsonEncode(p.toJson())).toList(),
    );
    if (await getActiveProfileId() == id) {
      await clearActiveProfileId();
    }
  }

  Future<void> setActiveProfileId(String id) async {
    final prefs = await _prefs();
    await prefs.setString(_activeProfileIdKey, id);
  }

  Future<void> clearActiveProfileId() async {
    final prefs = await _prefs();
    await prefs.remove(_activeProfileIdKey);
  }

  Future<String?> getActiveProfileId() async {
    try {
      final prefs = await _prefs();
      return prefs.getString(_activeProfileIdKey);
    } catch (e) {
      debugPrint('[ProfileStorage] falha ao ler perfil ativo: $e');
      return null;
    }
  }
}
