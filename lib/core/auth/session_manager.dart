import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager instance = SessionManager._internal();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLandlordId = 'landlord_id';
  static const String _keyUsername = 'username';
  static const String _keyDisplayName = 'display_name';
  static const String _keyEmail = 'email';
  static const String _keyPhone = 'phone';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyDarkMode = 'dark_mode';

  SharedPreferences? _prefs;

  SessionManager._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;
  int get landlordId => _prefs?.getInt(_keyLandlordId) ?? 101;
  String get username => _prefs?.getString(_keyUsername) ?? 'araf.landlord';
  String get displayName => _prefs?.getString(_keyDisplayName) ?? 'Arafat Hossain';
  String get email => _prefs?.getString(_keyEmail) ?? 'landlord.arafat@gmail.com';
  String get phone => _prefs?.getString(_keyPhone) ?? '+880 1711-987654';
  bool get biometricEnabled => _prefs?.getBool(_keyBiometricEnabled) ?? false;
  bool get isDarkMode => _prefs?.getBool(_keyDarkMode) ?? false;

  Future<void> loginDemoLandlord() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    await _prefs!.setBool(_keyIsLoggedIn, true);
    await _prefs!.setInt(_keyLandlordId, 101);
    await _prefs!.setString(_keyUsername, 'araf.landlord');
    await _prefs!.setString(_keyDisplayName, 'Arafat Hossain');
    await _prefs!.setString(_keyEmail, 'landlord.arafat@gmail.com');
    await _prefs!.setString(_keyPhone, '+880 1711-987654');
    notifyListeners();
  }

  Future<void> loginCustom(String user, String pass) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    await _prefs!.setBool(_keyIsLoggedIn, true);
    await _prefs!.setInt(_keyLandlordId, 102);
    await _prefs!.setString(_keyUsername, user);
    await _prefs!.setString(_keyDisplayName, user);
    await _prefs!.setString(_keyEmail, '${user.toLowerCase()}@landlord.io');
    await _prefs!.setString(_keyPhone, '+880 1700-000000');
    notifyListeners();
  }

  Future<void> updateProfile(String name, String mail, String mobile) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString(_keyDisplayName, name);
    await _prefs!.setString(_keyEmail, mail);
    await _prefs!.setString(_keyPhone, mobile);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool val) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    await _prefs!.setBool(_keyBiometricEnabled, val);
    notifyListeners();
  }

  Future<void> setDarkMode(bool val) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    await _prefs!.setBool(_keyDarkMode, val);
    notifyListeners();
  }

  Future<void> logout() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    await _prefs!.remove(_keyIsLoggedIn);
    notifyListeners();
  }
}
