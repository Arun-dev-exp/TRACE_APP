import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class AuditorHomePage extends StatelessWidget {
  const AuditorHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final projects = MockApi.I.projects;
    final inspections = MockApi.I.inspections;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Field Auditor', style: t.bodySmall),
          Text(AppState().name.isEmpty ? 'Inspector' : AppState().name, style: t.headlineSmall),
        ]),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () => context.push('/auditor/scan'),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: [t.primary, const Color(0xFF173A5E)])),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Scan Project QR', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Pull up the on-chain contract & start inspection.',
                    style: TextStyle(color: Colors.white70)),
                ])),
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Assigned inspections',
            child: Column(children: projects.map((p) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: t.primary.withOpacity(0.1), child: Icon(Icons.place_outlined, color: t.primary)),
              title: Text(p.name, style: t.titleMedium),
              subtitle: Text('${p.id} • Due ${DateFormat('d MMM').format(DateTime.now().add(const Duration(days: 4)))}'),
              trailing: Icon(Icons.chevron_right, color: t.secondaryText),
              onTap: () => context.push('/auditor/inspect?pid=${p.id}'),
            )).toList()),
          ),
          SectionCard(
            title: 'Recent inspections',
            child: Column(children: inspections.map((i) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: statusColor(i.verdict, context).withOpacity(0.1), child: Icon(Icons.assignment_turned_in_outlined, color: statusColor(i.verdict, context))),
              title: Text(i.id ?? '-', style: t.titleMedium),
              subtitle: Text('${i.projectId} • ${DateFormat('d MMM').format(i.createdAt)}'),
              trailing: StatusPill(label: i.verdict, color: statusColor(i.verdict, context)),
              onTap: () => context.push('/auditor/detail?id=${i.id}'),
            )).toList()),
          ),
        ],
      ),
    );
  }
}
