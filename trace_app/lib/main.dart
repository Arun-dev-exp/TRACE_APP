import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'pages/onboarding/splash_page.dart';
import 'pages/onboarding/role_select_page.dart';
import 'pages/onboarding/otp_page.dart';
import 'pages/onboarding/profile_setup_page.dart';
import 'pages/citizen/citizen_home_page.dart';
import 'pages/citizen/report_issue_page.dart';
import 'pages/citizen/scheme_status_page.dart';
import 'pages/citizen/my_reports_page.dart';
import 'pages/auditor/auditor_home_page.dart';
import 'pages/auditor/qr_scan_page.dart';
import 'pages/auditor/inspection_form_page.dart';
import 'pages/auditor/inspection_detail_page.dart';
import 'pages/contractor/contractor_home_page.dart';
import 'pages/contractor/submit_invoice_page.dart';
import 'pages/contractor/submit_milestone_page.dart';
import 'pages/contractor/payment_tracker_page.dart';

void main() => runApp(const TraceApp());

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/role', builder: (_, __) => const RoleSelectPage()),
    GoRoute(path: '/otp', builder: (_, s) => OtpPage(phone: s.uri.queryParameters['phone'] ?? '')),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileSetupPage()),
    // Citizen
    GoRoute(path: '/citizen', builder: (_, __) => const CitizenHomePage()),
    GoRoute(path: '/citizen/report', builder: (_, __) => const ReportIssuePage()),
    GoRoute(path: '/citizen/schemes', builder: (_, __) => const SchemeStatusPage()),
    GoRoute(path: '/citizen/my-reports', builder: (_, __) => const MyReportsPage()),
    // Auditor
    GoRoute(path: '/auditor', builder: (_, __) => const AuditorHomePage()),
    GoRoute(path: '/auditor/scan', builder: (_, __) => const QrScanPage()),
    GoRoute(path: '/auditor/inspect', builder: (_, s) => InspectionFormPage(projectId: s.uri.queryParameters['pid'] ?? 'JHS-RD-017')),
    GoRoute(path: '/auditor/detail', builder: (_, s) => InspectionDetailPage(id: s.uri.queryParameters['id'] ?? '')),
    // Contractor
    GoRoute(path: '/contractor', builder: (_, __) => const ContractorHomePage()),
    GoRoute(path: '/contractor/invoice', builder: (_, __) => const SubmitInvoicePage()),
    GoRoute(path: '/contractor/milestone', builder: (_, __) => const SubmitMilestonePage()),
    GoRoute(path: '/contractor/payments', builder: (_, s) => PaymentTrackerPage(contractId: s.uri.queryParameters['cid'] ?? 'JHS-RD-017')),
  ],
);

class TraceApp extends StatelessWidget {
  const TraceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppState(),
      child: Builder(builder: (context) {
        final t = FlutterFlowTheme.of(context);
        return MaterialApp.router(
          title: 'TRACE',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: t.primary, primary: t.primary),
            scaffoldBackgroundColor: t.primaryBackground,
            textTheme: GoogleFonts.interTextTheme(),
            appBarTheme: AppBarTheme(
              backgroundColor: t.primaryBackground, foregroundColor: t.primaryText,
              elevation: 0, centerTitle: false,
              titleTextStyle: t.headlineSmall,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.primary, width: 1.4)),
            ),
          ),
        );
      }),
    );
  }
}
