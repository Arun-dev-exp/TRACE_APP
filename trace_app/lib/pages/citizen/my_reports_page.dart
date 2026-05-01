import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final reports = MockApi.I.myReports;
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: reports.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inbox_outlined, size: 72, color: t.secondaryText),
              const SizedBox(height: 12),
              Text('No reports yet', style: t.headlineSmall),
              const SizedBox(height: 4),
              Text('Your submitted reports will appear here.', style: t.bodyMedium.copyWith(color: t.secondaryText)),
            ]))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: reports.map((r) => SectionCard(
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: t.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.description_outlined, color: t.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.id ?? '-', style: t.titleMedium),
                    Text('${r.category} • ${DateFormat('d MMM, HH:mm').format(r.createdAt)}', style: t.bodySmall),
                  ])),
                  StatusPill(label: r.status, color: statusColor(r.status, context)),
                ]),
              )).toList(),
            ),
    );
  }
}
