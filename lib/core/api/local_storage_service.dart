import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token in secure storage, identity in SharedPreferences.
class LocalStorageService {
  LocalStorageService([FlutterSecureStorage? storage])
    : _secure = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  static const _tokenKey = 'auth_token';
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';
  static const _userIdKey = 'auth_user_id';
  static const _onboardingSeenKey = 'onboarding_seen';
  static const _customRateTourSeenKey = 'custom_rate_tour_seen';

  Future<String?> readToken() => _secure.read(
    key: _tokenKey,
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  Future<String?> readName() async =>
      (await SharedPreferences.getInstance()).getString(_nameKey);

  Future<String?> readEmail() async =>
      (await SharedPreferences.getInstance()).getString(_emailKey);

  Future<String?> readUserId() async =>
      (await SharedPreferences.getInstance()).getString(_userIdKey);

  Future<bool> readOnboardingSeen() async =>
      (await SharedPreferences.getInstance()).getBool(_onboardingSeenKey) ??
      false;

  Future<void> writeOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }

  Future<bool> readCustomRateTourSeen() async =>
      (await SharedPreferences.getInstance()).getBool(_customRateTourSeenKey) ??
      false;

  Future<void> writeCustomRateTourSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_customRateTourSeenKey, true);
  }

  Future<void> writeSession({
    required String token,
    String? userId,
    String? name,
    String? email,
  }) async {
    await _secure.write(
      key: _tokenKey,
      value: token,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) await prefs.setString(_userIdKey, userId);
    if (name != null) await prefs.setString(_nameKey, name);
    if (email != null) await prefs.setString(_emailKey, email);
  }

  Future<void> clear() async {
    await _secure.delete(
      key: _tokenKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userIdKey);
  }

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    sharedPreferencesName: 'secure_auth',
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );
}
