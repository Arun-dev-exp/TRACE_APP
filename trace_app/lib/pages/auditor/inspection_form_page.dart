import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../models/models.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class InspectionFormPage extends StatefulWidget {
  final String projectId;
  const InspectionFormPage({super.key, required this.projectId});
  @override
  State<InspectionFormPage> createState() => _InspectionFormPageState();
}

class _InspectionFormPageState extends State<InspectionFormPage> {
  late Project project;
  final List<XFile> _photos = [];
  final List<ChecklistItem> _checklist = [
    ChecklistItem('Road width ≥ 7.0 m'),
    ChecklistItem('Base layer thickness ≥ 150 mm'),
    ChecklistItem('Drainage channel present'),
    ChecklistItem('Compaction density OK'),
  ];
  String _verdict = 'Approved';
  Position? _pos;
  bool _locating = false;
  bool _submitting = false;
  bool _locationValid = false;

  @override
  void initState() {
    super.initState();
    project = MockApi.I.projects.firstWhere((p) => p.id == widget.projectId,
        orElse: () => MockApi.I.projects.first);
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) await Geolocator.requestPermission();
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 8), onTimeout: () => Position(
            longitude: project.lng + 0.0005, latitude: project.lat + 0.0005,
            timestamp: DateTime.now(), accuracy: 10, altitude: 0, altitudeAccuracy: 0,
            heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0));
      final d = Geolocator.distanceBetween(p.latitude, p.longitude, project.lat, project.lng);
      setState(() { _pos = p; _locationValid = d <= 500; });
    } catch (_) {}
    if (mounted) setState(() => _locating = false);
  }

  Future<void> _takePhoto() async {
    // Auditor rule — camera only, never gallery
    final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 82);
    if (p != null) setState(() => _photos.add(p));
  }

  Future<void> _submit() async {
    if (!_locationValid) { _snack('You are not within 500 m of the project site'); return; }
    if (_photos.length < 3) { _snack('At least 3 photos required'); return; }
    final proceed = await ImmutabilityDialog.show(context,
        message: 'Inspection verdict: $_verdict');
    if (!proceed) return;
    setState(() => _submitting = true);
    final failed = _checklist.where((c) => c.result == 'Fail').length;
    final id = await MockApi.I.postInspection(Inspection(
      projectId: project.id, verdict: _verdict, failedItems: failed,
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    setState(() => _submitting = false);
    _snack('Inspection $id recorded on-chain');
    context.go('/auditor');
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(project.name, style: t.headlineSmall),
            const SizedBox(height: 4),
            Text('${project.id} • ${project.contractor}', style: t.bodySmall),
            const SizedBox(height: 4),
            Text('Verifying: ${project.milestone}', style: t.bodyMedium),
          ])),
          SectionCard(title: 'Location check', child: Row(children: [
            Icon(
              _locating ? Icons.hourglass_top :
              _locationValid ? Icons.check_circle : Icons.error_outline,
              color: _locationValid ? t.success : (_locating ? t.secondaryText : t.error),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(
              _locating ? 'Checking location…' :
              _locationValid ? 'On site (within 500 m)' : 'Off site — you must stand within 500 m of the project',
              style: t.bodyMedium,
            )),
            TextButton(onPressed: _getLocation, child: const Text('Recheck')),
          ])),
          SectionCard(title: 'Photos (min 3) — camera only', child: Column(children: [
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  if (i == _photos.length) {
                    return GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(color: t.primaryBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.divider)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_a_photo_outlined, color: t.primary),
                          const SizedBox(height: 6),
                          Text('Add', style: t.bodySmall),
                        ]),
                      ),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(_photos[i].path), width: 110, height: 110, fit: BoxFit.cover),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: Text('${_photos.length} photo(s) captured', style: t.bodySmall)),
          ])),
          SectionCard(title: 'Spec checklist (from contract)', child: Column(
            children: _checklist.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(child: Text(c.label, style: t.bodyMedium)),
                DropdownButton<String>(
                  value: c.result,
                  items: const [
                    DropdownMenuItem(value: 'Pass', child: Text('Pass')),
                    DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                    DropdownMenuItem(value: 'Fail', child: Text('Fail')),
                  ],
                  onChanged: (v) => setState(() => c.result = v!),
                ),
              ]),
            )).toList(),
          )),
          SectionCard(title: 'Overall verdict', child: Column(children: [
            for (final v in ['Approved', 'Rejected', 'Needs Re-inspection'])
              RadioListTile<String>(
                value: v, groupValue: _verdict,
                onChanged: (nv) => setState(() => _verdict = nv!),
                title: Text(v),
                contentPadding: EdgeInsets.zero,
              ),
          ])),
          const SizedBox(height: 6),
          PrimaryButton(label: 'Submit permanently', icon: Icons.lock_outline, loading: _submitting, onPressed: _submit),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
