import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class ProfileStorageService {
  static const _profilesKey = 'contalibras_profiles';
  static const _activeProfileIdKey = 'contalibras_active_profile_id';

  Future<List<UserProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_profilesKey) ?? [];
    return raw
        .map((item) => UserProfile.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileIdKey, id);
  }

  Future<void> clearActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeProfileIdKey);
  }

  Future<String?> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileIdKey);
  }
}
