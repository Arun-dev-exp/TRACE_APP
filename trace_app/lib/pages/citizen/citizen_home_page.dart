import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class CitizenHomePage extends StatelessWidget {
  const CitizenHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final api = MockApi.I;
    final district = AppState().district;
    final hasFlagged = api.projects.any((p) => p.flagged);

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Namaste, ${AppState().name.isEmpty ? "Citizen" : AppState().name.split(" ").first}', style: t.bodySmall),
          Text(district, style: t.headlineSmall),
        ]),
        actions: [
          IconButton(onPressed: () => context.push('/citizen/my-reports'), icon: const Icon(Icons.receipt_long_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hasFlagged) const AlertBanner(text: 'A project in your district is flagged. Tap "Schemes" to see details.'),
          _HeroReportCta(),
          const SizedBox(height: 8),
          SectionCard(
            title: 'Active projects near me',
            child: Column(children: api.projects.map((p) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.divider))),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: t.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.construction, color: t.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${p.id} • ${p.contractor}', style: t.bodySmall),
                ])),
                if (p.flagged) const StatusPill(label: 'FLAGGED', color: Color(0xFFD32F2F)),
              ]),
            )).toList()),
          ),
          SectionCard(
            title: 'Scheme status in $district',
            child: Column(children: [
              ...api.schemes.take(2).map((s) => _SchemeRow(name: s.name, allocated: s.allocated, returned: s.returned, color: schemeColor(s.status, context))),
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
    );
  }
}

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
          gradient: LinearGradient(colors: [t.primary, t.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Report an Issue', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Photo + GPS — it lands on the auditor\'s desk in seconds.',
              style: TextStyle(color: Colors.white.withOpacity(0.85))),
          ])),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
          ),
        ]),
      ),
    );
  }
}

class _SchemeRow extends StatelessWidget {
  final String name;
  final double allocated, returned;
  final Color color;
  const _SchemeRow({required this.name, required this.allocated, required this.returned, required this.color});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final pct = (returned / allocated).clamp(0, 1).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name, style: t.titleMedium)),
          StatusPill(label: '₹$returned Cr returned', color: color),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: t.divider, valueColor: AlwaysStoppedAnimation(color)),
        ),
        const SizedBox(height: 4),
        Text('Allocated ₹$allocated Cr', style: t.bodySmall),
      ]),
    );
  }
}
