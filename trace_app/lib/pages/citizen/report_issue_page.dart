import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../models/models.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});
  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  static const _cats = ['Road Quality', 'Ghost Project', 'Suspicious Activity', 'Other'];
  String _category = 'Road Quality';
  XFile? _photo;
  Position? _pos;
  bool _locating = false;
  bool _submitting = false;
  final _desc = TextEditingController();
  String? _suggestedProjectId;

  @override
  void initState() { super.initState(); _getLocation(); }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      final ok = await Geolocator.checkPermission();
      if (ok == LocationPermission.denied) await Geolocator.requestPermission();
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 8), onTimeout: () => Position(
            longitude: 78.5685, latitude: 25.4484, timestamp: DateTime.now(),
            accuracy: 10, altitude: 0, altitudeAccuracy: 0, heading: 0,
            headingAccuracy: 0, speed: 0, speedAccuracy: 0));
      _pos = p;
      // Suggest nearest project
      for (final proj in MockApi.I.projects) {
        final d = Geolocator.distanceBetween(p.latitude, p.longitude, proj.lat, proj.lng);
        if (d < 1500) { _suggestedProjectId = proj.id; break; }
      }
    } catch (_) {}
    if (mounted) setState(() => _locating = false);
  }

  Future<void> _takePhoto() async {
    final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 78);
    if (p != null) setState(() => _photo = p);
  }

  Future<void> _submit() async {
    if (_photo == null) { _snack('Photo is mandatory'); return; }
    if (_pos == null) { _snack('GPS is mandatory — turn on location'); return; }
    setState(() => _submitting = true);
    final id = await MockApi.I.postReport(Report(
      category: _category, description: _desc.text, photoPath: _photo!.path,
      lat: _pos!.latitude, lng: _pos!.longitude, projectId: _suggestedProjectId,
    ));
    if (!mounted) return;
    setState(() => _submitting = false);
    showDialog(context: context, builder: (_) => _SubmittedDialog(reportId: id));
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Category',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _cats.map((c) => ChoiceChip(
                label: Text(c),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
                selectedColor: t.primary,
                labelStyle: TextStyle(color: _category == c ? Colors.white : t.primaryText, fontWeight: FontWeight.w600),
              )).toList(),
            ),
          ),
          SectionCard(
            title: 'Photo (required)',
            child: GestureDetector(
              onTap: _takePhoto,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: t.primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.divider, style: BorderStyle.solid),
                ),
                child: _photo == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.photo_camera_outlined, size: 42, color: t.secondaryText),
                        const SizedBox(height: 8),
                        Text('Tap to open camera', style: t.bodyMedium.copyWith(color: t.secondaryText)),
                      ])
                    : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_photo!.path), fit: BoxFit.cover, width: double.infinity)),
              ),
            ),
          ),
          SectionCard(
            title: 'Location (auto)',
            child: Row(children: [
              Icon(Icons.location_on, color: t.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(
                _locating ? 'Fetching GPS…'
                    : _pos == null ? 'Location unavailable' :
                    '${_pos!.latitude.toStringAsFixed(5)}, ${_pos!.longitude.toStringAsFixed(5)}',
                style: t.bodyMedium,
              )),
              TextButton(onPressed: _getLocation, child: const Text('Refresh')),
            ]),
          ),
          if (_suggestedProjectId != null) SectionCard(
            child: Row(children: [
              Icon(Icons.link, color: t.secondary),
              const SizedBox(width: 10),
              Expanded(child: Text('Linking to nearby project ${_suggestedProjectId!}', style: t.bodyMedium)),
            ]),
          ),
          SectionCard(
            title: 'Description (optional)',
            child: TextField(
              controller: _desc, maxLength: 200, maxLines: 3,
              decoration: const InputDecoration(hintText: 'What did you see?'),
            ),
          ),
          const SizedBox(height: 6),
          PrimaryButton(label: 'Submit report', icon: Icons.send_rounded, loading: _submitting, onPressed: _submit),
        ],
      ),
    );
  }
}

class _SubmittedDialog extends StatelessWidget {
  final String reportId;
  const _SubmittedDialog({required this.reportId});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle, color: t.success, size: 56),
        const SizedBox(height: 12),
        Text('Report submitted', style: t.headlineSmall),
        const SizedBox(height: 8),
        Text('Reference: $reportId', style: t.bodyMedium.copyWith(color: t.secondaryText)),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Back to home', onPressed: () {
          Navigator.pop(context); context.pop();
        }),
      ]),
    );
  }
}
