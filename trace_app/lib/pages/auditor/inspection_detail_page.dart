import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class InspectionDetailPage extends StatelessWidget {
  final String id;
  const InspectionDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final i = MockApi.I.inspections.firstWhere((x) => x.id == id,
        orElse: () => MockApi.I.inspections.first);
    return Scaffold(
      appBar: AppBar(title: Text(i.id ?? 'Inspection'),
        actions: [IconButton(onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF export — roadmap')));
        }, icon: const Icon(Icons.picture_as_pdf_outlined))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Verdict', style: t.bodySmall)),
              StatusPill(label: i.verdict, color: statusColor(i.verdict, context)),
            ]),
            const SizedBox(height: 10),
            Text('Project: ${i.projectId}', style: t.titleMedium),
            const SizedBox(height: 4),
            Text('Submitted ${DateFormat('d MMM yyyy, HH:mm').format(i.createdAt)}', style: t.bodySmall),
            const SizedBox(height: 4),
            Text('Failed checklist items: ${i.failedItems}', style: t.bodyMedium),
          ])),
          SectionCard(title: 'GPS stamp', child: Text('25.4484, 78.5685 (±6 m)', style: t.bodyMedium)),
          SectionCard(title: 'Photos', child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6, crossAxisSpacing: 6,
            children: List.generate(6, (_) => Container(
              decoration: BoxDecoration(color: t.primaryBackground, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.image_outlined, color: t.secondaryText),
            )),
          )),
        ],
      ),
    );
  }
}
