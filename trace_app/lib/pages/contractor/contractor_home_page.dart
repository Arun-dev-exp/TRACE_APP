import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class ContractorHomePage extends StatelessWidget {
  const ContractorHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final contracts = MockApi.I.contracts;
    final frozen = contracts.expand((c) => c.milestones).any((m) => m.status == 'Blocked');
    final risk = contracts.first.riskScore;
    final riskColor = risk >= 70 ? t.error : risk >= 40 ? t.warning : t.success;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Contractor', style: t.bodySmall),
          Text(AppState().name.isEmpty ? 'Bharat Infra Ltd' : AppState().name, style: t.headlineSmall),
        ]),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (frozen) const AlertBanner(text: 'A milestone payment is frozen. Tap the contract below to see why.'),
          SectionCard(
            title: 'Account risk score',
            child: Row(children: [
              Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 76, height: 76,
                  child: CircularProgressIndicator(
                    value: risk / 100, strokeWidth: 8,
                    backgroundColor: t.divider,
                    valueColor: AlwaysStoppedAnimation(riskColor),
                  ),
                ),
                Text('$risk', style: t.headlineSmall.copyWith(color: riskColor)),
              ]),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                StatusPill(label: risk >= 70 ? 'HIGH RISK' : risk >= 40 ? 'MEDIUM' : 'LOW', color: riskColor),
                const SizedBox(height: 6),
                Text('Auditor inspection on JHS-RD-017 failed 2 checks. Fix spec issues to reduce score.', style: t.bodyMedium),
              ])),
            ]),
          ),
          SectionCard(
            title: 'Active contracts',
            child: Column(children: contracts.map((c) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: t.primary.withOpacity(0.1), child: Icon(Icons.handshake_outlined, color: t.primary)),
              title: Text(c.name, style: t.titleMedium),
              subtitle: Text(c.id),
              trailing: Icon(Icons.chevron_right, color: t.secondaryText),
              onTap: () => context.push('/contractor/payments?cid=${c.id}'),
            )).toList()),
          ),
          Row(children: [
            Expanded(child: _QuickAction(icon: Icons.receipt_outlined, label: 'Submit invoice',
              onTap: () => context.push('/contractor/invoice'))),
            const SizedBox(width: 12),
            Expanded(child: _QuickAction(icon: Icons.flag_outlined, label: 'Submit milestone',
              onTap: () => context.push('/contractor/milestone'))),
          ]),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Material(
      color: t.secondaryBackground, borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: t.divider)),
          child: Column(children: [
            Icon(icon, color: t.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: t.titleMedium, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
