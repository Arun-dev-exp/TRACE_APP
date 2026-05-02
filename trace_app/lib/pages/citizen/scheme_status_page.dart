import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';

class SchemeStatusPage extends StatefulWidget {
  const SchemeStatusPage({super.key});
  @override
  State<SchemeStatusPage> createState() => _SchemeStatusPageState();
}

class _SchemeStatusPageState extends State<SchemeStatusPage> {
  List<Scheme> _schemes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final districtId = AppState().districtId;
    if (districtId.isEmpty) {
      setState(() { _loading = false; _error = 'District not set — go back and log in again.'; });
      return;
    }
    final result = await ApiService.I.getSchemes(districtId);
    if (!mounted) return;
    if (result.ok) {
      setState(() { _schemes = result.data!; _loading = false; });
    } else {
      setState(() { _error = result.error; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final district = AppState().district;
    return Scaffold(
      appBar: AppBar(title: Text('Scheme Status — $district')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _Err(msg: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: _schemes.map((s) => _SchemeCard(s: s)).toList(),
                  ),
                ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final Scheme s;
  const _SchemeCard({required this.s});
  @override
  Widget build(BuildContext context) {
    final t     = FlutterFlowTheme.of(context);
    final color = schemeColor(s.schemeStatus, context);
    final pct   = (s.returned / s.allocated).clamp(0.0, 1.0);
    return SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(s.name, style: t.headlineSmall)),
          StatusPill(label: s.status.toUpperCase(), color: color),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _Metric(label: 'Allocated', value: '₹${s.allocated.toStringAsFixed(1)} Cr'),
          const SizedBox(width: 8),
          _Metric(label: 'Returned',  value: '₹${s.returned.toStringAsFixed(1)} Cr', color: color),
          const SizedBox(width: 8),
          _Metric(label: 'Missing',   value: '₹${s.missingCrore.toStringAsFixed(1)} Cr',
              color: s.missingCrore > 5 ? t.error : t.success),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
              value: pct, minHeight: 10,
              backgroundColor: t.divider,
              valueColor: AlwaysStoppedAnimation(color)),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(pct * 100).toStringAsFixed(1)}% returned · Risk score ${s.riskScore}',
                style: t.bodySmall),
            TextButton.icon(
              onPressed: () => context.push('/citizen/report?scheme=${Uri.encodeComponent(s.name)}'),
              icon: Icon(Icons.report_problem_outlined, size: 16, color: t.error),
              label: Text('Report', style: t.bodyMedium.copyWith(color: t.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
        Text(value, style: t.titleMedium.copyWith(color: color ?? t.primaryText),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ));
  }
}

class _Err extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _Err({required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 56, color: t.error),
      const SizedBox(height: 12),
      Text(msg, style: t.bodyMedium, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      PrimaryButton(label: 'Retry', onPressed: onRetry),
    ]));
  }
}
