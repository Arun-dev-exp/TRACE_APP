import 'package:flutter/foundation.dart';

enum UserRole { none, citizen, auditor, contractor }

class AppState extends ChangeNotifier {
  static final AppState _i = AppState._();
  factory AppState() => _i;
  AppState._();

  UserRole role = UserRole.none;
  String phone = '';
  String name = '';
  String district = 'Jhansi';
  String aadhaarLast4 = '';
  bool loggedIn = false;

  void setRole(UserRole r) { role = r; notifyListeners(); }
  void setProfile({required String n, required String d, String a = ''}) {
    name = n; district = d; aadhaarLast4 = a; loggedIn = true; notifyListeners();
  }
  void logout() { role = UserRole.none; loggedIn = false; notifyListeners(); }
}
