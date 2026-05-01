import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class PaymentTrackerPage extends StatelessWidget {
  final String contractId;
  const PaymentTrackerPage({super.key, required this.contractId});

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final c = MockApi.I.contracts.firstWhere((x) => x.id == contractId,
        orElse: () => MockApi.I.contracts.first);
    final total = c.milestones.fold<double>(0, (a, m) => a + m.amount);
    final released = c.milestones.where((m) => m.status == 'Released').fold<double>(0, (a, m) => a + m.amount);

    return Scaffold(
      appBar: AppBar(title: Text(c.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: t.headlineSmall),
            const SizedBox(height: 10),
            Row(children: [
              _Stat(label: 'Released', value: '₹$released Cr', color: t.success),
              const SizedBox(width: 10),
              _Stat(label: 'Total', value: '₹$total Cr'),
            ]),
          ])),
          SectionCard(title: 'Milestone breakdown', child: Column(
            children: c.milestones.map((m) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.primaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.divider),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('Milestone ${m.index}', style: t.titleMedium)),
                  StatusPill(label: m.status, color: statusColor(m.status, context)),
                ]),
                const SizedBox(height: 6),
                Text('Amount: ₹${m.amount} Cr', style: t.bodyMedium),
                if (m.releasedAt != null) Text('Released on ${DateFormat('d MMM yyyy').format(m.releasedAt!)}', style: t.bodySmall),
                if (m.blockReason != null) Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: t.error.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Icon(Icons.block, color: t.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m.blockReason!, style: TextStyle(color: t.error))),
                    ]),
                  ),
                ),
              ]),
            )).toList(),
          )),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _Stat({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: t.primaryBackground, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: t.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: t.headlineSmall.copyWith(color: color ?? t.primaryText)),
      ]),
    ));
  }
}
