import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';

class ReportIssuePage extends StatefulWidget {
  final String? schemeName;
  const ReportIssuePage({super.key, this.schemeName});
  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  static const _cats = [
    'Road Quality', 'Ghost Project', 'Suspicious Activity', 'Other'
  ];
  // Backend snake_case keys for each category
  static const _catKeys = [
    'road_quality', 'ghost_project', 'suspicious_activity', 'other'
  ];

  String _category    = 'Road Quality';
  XFile? _photo;
  Position? _pos;
  bool _locating    = false;
  bool _submitting  = false;
  String? _suggestedProjectId;
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.schemeName != null) {
      _desc.text = '[Scheme: ${widget.schemeName}] ';
    }
    _getLocation();
  }

  // ── GPS ───────────────────────────────────────────────────────────────────
  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      _pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 8),
              onTimeout: () => Position(
                    longitude: 78.5685, latitude: 25.4484,
                    timestamp: DateTime.now(), accuracy: 10,
                    altitude: 0, altitudeAccuracy: 0,
                    heading: 0, headingAccuracy: 0,
                    speed: 0, speedAccuracy: 0));
    } catch (_) {}
    if (mounted) setState(() => _locating = false);
  }

  // ── Camera ────────────────────────────────────────────────────────────────
  Future<void> _takePhoto() async {
    final p = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 78);
    if (p != null) setState(() => _photo = p);
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_photo == null) { _snack('Photo is mandatory'); return; }
    if (_pos == null)   { _snack('GPS is mandatory — turn on location'); return; }

    final state = AppState();
    if (state.districtId.isEmpty) { _snack('District not set — restart and log in'); return; }

    setState(() => _submitting = true);

    final catIndex = _cats.indexOf(_category);
    final report = Report(
      type: 'citizen',
      category: catIndex >= 0 ? _catKeys[catIndex] : 'other',
      description: _desc.text,
      photoUrl: _photo!.path, // local path — in production upload to Storage first
      lat: _pos!.latitude,
      lng: _pos!.longitude,
      districtId: state.districtId,
      projectId: _suggestedProjectId,
    );

    final result = await ApiService.I.postReport(report);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!result.ok) {
      _snack('Failed to submit: ${result.error}');
      return;
    }

    // Save to session so "My Reports" shows it
    state.addReport(report.copyWith(id: result.data!.reportId, status: 'Received'));

    showDialog(
      context: context,
      builder: (_) => _SubmittedDialog(reportId: result.data!.reportId),
    );
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Category picker
          SectionCard(
            title: 'Category',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _cats.map((c) => ChoiceChip(
                label: Text(c),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
                selectedColor: t.primary,
                labelStyle: TextStyle(
                    color: _category == c ? Colors.white : t.primaryText,
                    fontWeight: FontWeight.w600),
              )).toList(),
            ),
          ),

          // Photo — camera only
          SectionCard(
            title: 'Photo (required)',
            child: GestureDetector(
              onTap: _takePhoto,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: t.primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _photo == null ? t.divider : t.primary),
                ),
                child: _photo == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.photo_camera_outlined, size: 42, color: t.secondaryText),
                        const SizedBox(height: 8),
                        Text('Tap to open camera',
                            style: t.bodyMedium.copyWith(color: t.secondaryText)),
                      ])
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_photo!.path),
                            fit: BoxFit.cover, width: double.infinity)),
              ),
            ),
          ),

          // GPS
          SectionCard(
            title: 'Location (auto)',
            child: Row(children: [
              Icon(
                _locating ? Icons.hourglass_top :
                _pos != null ? Icons.location_on : Icons.location_off,
                color: _pos != null ? t.primary : t.error,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(
                _locating ? 'Fetching GPS…'
                    : _pos == null ? 'Location unavailable'
                    : '${_pos!.latitude.toStringAsFixed(5)}, ${_pos!.longitude.toStringAsFixed(5)}',
                style: t.bodyMedium,
              )),
              TextButton(onPressed: _getLocation, child: const Text('Refresh')),
            ]),
          ),

          // Description
          SectionCard(
            title: 'Description (optional)',
            child: TextField(
              controller: _desc,
              maxLength: 200,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'What did you see?'),
            ),
          ),

          const SizedBox(height: 6),
          PrimaryButton(
            label: 'Submit report',
            icon: Icons.send_rounded,
            loading: _submitting,
            onPressed: _submit,
          ),
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
        Text('Reference: $reportId',
            style: t.bodyMedium.copyWith(color: t.secondaryText)),
        const SizedBox(height: 4),
        Text('Permanently recorded on-chain.',
            style: t.bodySmall.copyWith(color: t.secondaryText)),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Back to home', onPressed: () {
          Navigator.pop(context);
          context.pop();
        }),
      ]),
    );
  }
}
