import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../models/models.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class SchemeStatusPage extends StatelessWidget {
  const SchemeStatusPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Scheme Status')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: MockApi.I.schemes.map((s) => _SchemeCard(s: s)).toList(),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final Scheme s;
  const _SchemeCard({required this.s});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final color = schemeColor(s.status, context);
    final pct = (s.returned / s.allocated).clamp(0, 1).toDouble();
    return SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(s.name, style: t.headlineSmall)),
          StatusPill(label: s.status.name.toUpperCase(), color: color),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _Metric(label: 'Allocated', value: '₹${s.allocated} Cr'),
          const SizedBox(width: 12),
          _Metric(label: 'Returned', value: '₹${s.returned} Cr', color: color),
          const SizedBox(width: 12),
          _Metric(label: 'Beneficiaries', value: '${(s.beneficiaries / 1000).toStringAsFixed(1)}k'),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: pct, minHeight: 10, backgroundColor: t.divider, valueColor: AlwaysStoppedAnimation(color)),
        ),
        const SizedBox(height: 6),
        Text('${(pct * 100).toStringAsFixed(1)}% of allocation returned unspent', style: t.bodySmall),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _Metric({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: t.primaryBackground, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: t.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: t.titleMedium.copyWith(color: color ?? t.primaryText)),
      ]),
    ));
  }
}
