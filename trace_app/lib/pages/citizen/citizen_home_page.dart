import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});
  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage> {
  List<District> _allDistricts = [];
  List<Project>  _projects     = [];
  List<Scheme>   _schemes      = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });

    // Fetch districts first to resolve districtId from name
    final dResult = await ApiService.I.getDistricts();
    if (!mounted) return;
    if (!dResult.ok) {
      setState(() { _loading = false; _error = dResult.error; });
      return;
    }
    _allDistricts = dResult.data!;

    // Match the user's selected district to its UUID
    final state = AppState();
    final match = _allDistricts.firstWhere(
      (d) => d.name.toLowerCase() == state.district.toLowerCase(),
      orElse: () => _allDistricts.first,
    );
    if (state.districtId.isEmpty) {
      state.districtId = match.id;
    }

    // Fetch actual projects for this district
    final pResult = await ApiService.I.getProjects(match.id);
    if (!mounted) return;
    if (pResult.ok) {
      _projects = pResult.data!.take(3).toList();
    }

    // Fetch schemes for this district
    final sResult = await ApiService.I.getSchemes(match.id);
    if (!mounted) return;
    if (sResult.ok) _schemes = sResult.data!;

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t       = FlutterFlowTheme.of(context);
    final state   = AppState();
    final hasFlagged = _projects.any((p) => p.flagged);

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Namaste, Citizen', style: TextStyle(fontSize: 14)),
          Text(state.district, style: t.headlineSmall),
        ]),
        actions: [
          IconButton(
            onPressed: () => context.push('/citizen/my-reports'),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (hasFlagged)
                        const AlertBanner(
                            text: 'A project in your district is flagged 🔴'),
                      _HeroReportCta(),
                      const SizedBox(height: 8),
                      _SmartGovernanceCta(),
                      const SizedBox(height: 12),

                      // ── Active projects ──────────────────────────────────
                      SectionCard(
                        title: 'Active projects near me',
                        child: _projects.isEmpty
                            ? Text('No flagged projects in your area.',
                                style: t.bodyMedium)
                            : Column(
                                children: _projects
                                    .map((p) => _ProjectRow(project: p))
                                    .toList(),
                              ),
                      ),

                      // ── Scheme status (top 2) ────────────────────────────
                      SectionCard(
                        title: 'Scheme status in ${state.district}',
                        child: Column(children: [
                          ..._schemes.take(2).map((s) => _SchemeRow(scheme: s)),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => context.push('/citizen/schemes'),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('View all schemes'),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _HeroReportCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => context.push('/citizen/report'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
              colors: [t.primary, t.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Report an Issue',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Photo + GPS — recorded permanently.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85))),
            ]),
          ),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
          ),
        ]),
      ),
    );
  }
}

class _SmartGovernanceCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => context.push('/simulation'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.secondary),
          boxShadow: [
            BoxShadow(color: t.secondary.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: t.secondary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('See TRACE AI in Action', style: t.titleMedium.copyWith(color: t.secondary)),
                  Text('Watch how tenders are securely awarded', style: t.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: t.secondary),
          ],
        ),
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final Project project;
  const _ProjectRow({required this.project});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.divider))),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: t.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.construction, color: t.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(project.name, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(project.districtName, style: t.bodySmall),
          ]),
        ),
        if (project.flagged) const StatusPill(label: 'FLAGGED', color: Color(0xFFD32F2F)),
      ]),
    );
  }
}

class _SchemeRow extends StatelessWidget {
  final Scheme scheme;
  const _SchemeRow({required this.scheme});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final color = schemeColor(scheme.schemeStatus, context);
    final pct = (scheme.returned / scheme.allocated).clamp(0.0, 1.0);
    return InkWell(
      onTap: () => context.push('/citizen/report?scheme=${Uri.encodeComponent(scheme.name)}'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(scheme.name, style: t.titleMedium)),
            StatusPill(
                label: '₹${scheme.returned.toStringAsFixed(1)} Cr returned',
                color: color),
            const SizedBox(width: 8),
            Icon(Icons.report_problem_outlined, size: 18, color: t.secondaryText),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: t.divider,
                valueColor: AlwaysStoppedAnimation(color)),
          ),
          const SizedBox(height: 4),
          Text('Allocated ₹${scheme.allocated.toStringAsFixed(1)} Cr', style: t.bodySmall),
        ]),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_off_outlined, size: 64, color: t.error),
          const SizedBox(height: 16),
          Text('Could not load data', style: t.headlineSmall),
          const SizedBox(height: 8),
          Text(message, style: t.bodyMedium.copyWith(color: t.secondaryText), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
        ]),
      ),
    );
  }
}
