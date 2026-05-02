import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/models.dart';

enum UserRole { none, citizen, auditor, contractor }

class AppState extends ChangeNotifier {
  static final AppState _i = AppState._();
  factory AppState() => _i;
  AppState._();

  // ── Session ──────────────────────────────────────────────────────────────────
  UserRole role = UserRole.citizen; // Default to citizen
  String phone = '';
  String name = 'Citizen';
  String district = '';       // human-readable
  String districtId = '';           // UUID from backend — used in API calls
  String aadhaarLast4 = '';
  bool loggedIn = true; // Anonymous is considered logged in for citizen app
  String? token;
  bool isInitialized = false;

  // ── In-session state (reports submitted this session) ────────────────────────
  List<Report> myReports = [];

  // ── Initialization ───────────────────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    district = prefs.getString('district') ?? '';
    districtId = prefs.getString('districtId') ?? '';
    
    final reportsJson = prefs.getStringList('myReports') ?? [];
    myReports = reportsJson.map((r) {
      try {
        return Report.fromJson(jsonDecode(r));
      } catch (_) {
        return null;
      }
    }).where((r) => r != null).cast<Report>().toList();

    isInitialized = true;
    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String get apiRole => 'public'; // Force public for API

  Future<void> setDistrict(String d, String dId) async {
    district = d;
    districtId = dId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('district', district);
    await prefs.setString('districtId', districtId);
    notifyListeners();
  }

  Future<void> addReport(Report r) async {
    myReports.insert(0, r);
    final prefs = await SharedPreferences.getInstance();
    final List<String> reportsJson = myReports.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('myReports', reportsJson);
    notifyListeners();
  }

  Future<void> clearDistrict() async {
    district = '';
    districtId = '';
    myReports.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('district');
    await prefs.remove('districtId');
    await prefs.remove('myReports');
    notifyListeners();
  }
}
