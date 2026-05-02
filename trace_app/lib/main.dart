import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'pages/onboarding/splash_page.dart';
import 'pages/onboarding/district_select_page.dart';
import 'pages/citizen/citizen_home_page.dart';
import 'pages/citizen/report_issue_page.dart';
import 'pages/citizen/scheme_status_page.dart';
import 'pages/citizen/my_reports_page.dart';
import 'pages/shared/blockchain_ledger_page.dart';
import 'pages/shared/tender_simulation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState().init();
  runApp(const TraceApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/district-select', builder: (_, __) => const DistrictSelectPage()),
    // Citizen
    GoRoute(path: '/citizen', builder: (_, __) => const CitizenHomePage()),
    GoRoute(path: '/citizen/report', builder: (_, s) => ReportIssuePage(schemeName: s.uri.queryParameters['scheme'])),
    GoRoute(path: '/citizen/schemes', builder: (_, __) => const SchemeStatusPage()),
    GoRoute(path: '/citizen/my-reports', builder: (_, __) => const MyReportsPage()),
    // Shared
    GoRoute(path: '/blockchain', builder: (_, __) => const BlockchainLedgerPage()),
    GoRoute(path: '/simulation', builder: (_, __) => const TenderSimulationPage()),
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
