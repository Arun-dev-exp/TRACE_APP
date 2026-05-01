import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class SubmitMilestonePage extends StatefulWidget {
  const SubmitMilestonePage({super.key});
  @override
  State<SubmitMilestonePage> createState() => _SubmitMilestonePageState();
}

class _SubmitMilestonePageState extends State<SubmitMilestonePage> {
  String _contract = 'JHS-RD-017';
  int _milestone = 2;
  final List<XFile> _photos = [];
  Position? _pos;
  bool _locating = false;
  bool _locationValid = false;
  bool _submitting = false;

  @override
  void initState() { super.initState(); _getLocation(); }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) await Geolocator.requestPermission();
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 8), onTimeout: () => Position(
            longitude: 78.5690, latitude: 25.4486,
            timestamp: DateTime.now(), accuracy: 10, altitude: 0, altitudeAccuracy: 0,
            heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0));
      final proj = MockApi.I.projects.firstWhere((x) => x.id == _contract, orElse: () => MockApi.I.projects.first);
      final d = Geolocator.distanceBetween(p.latitude, p.longitude, proj.lat, proj.lng);
      setState(() { _pos = p; _locationValid = d <= 500; });
    } catch (_) {}
    if (mounted) setState(() => _locating = false);
  }

  Future<void> _takePhoto() async {
    final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 82);
    if (p != null) setState(() => _photos.add(p));
  }

  Future<void> _submit() async {
    if (!_locationValid) { _snack('GPS must match project location'); return; }
    if (_photos.length < 5) { _snack('At least 5 completion photos required'); return; }
    final proceed = await ImmutabilityDialog.show(context,
        message: 'Submitting milestone $_milestone for $_contract.');
    if (!proceed) return;
    setState(() => _submitting = true);
    final id = await MockApi.I.postMilestone(_contract, _milestone);
    setState(() => _submitting = false);
    if (!mounted) return;
    _snack('Milestone $id submitted → 3-layer verification triggered');
    context.pop();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Submit milestone')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(title: 'Contract', child: DropdownButtonFormField<String>(
            value: _contract,
            items: MockApi.I.contracts.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.id} — ${c.name}'))).toList(),
            onChanged: (v) { setState(() => _contract = v!); _getLocation(); },
          )),
          SectionCard(title: 'Milestone', child: DropdownButtonFormField<int>(
            value: _milestone,
            items: List.generate(4, (i) => i + 1).map((i) => DropdownMenuItem(value: i, child: Text('Milestone $i of 4'))).toList(),
            onChanged: (v) => setState(() => _milestone = v!),
          )),
          SectionCard(title: 'Location check', child: Row(children: [
            Icon(_locationValid ? Icons.check_circle : Icons.error_outline, color: _locationValid ? t.success : t.error),
            const SizedBox(width: 8),
            Expanded(child: Text(_locating ? 'Checking…' : _locationValid ? 'GPS matches project' : 'Off site', style: t.bodyMedium)),
            TextButton(onPressed: _getLocation, child: const Text('Recheck')),
          ])),
          SectionCard(title: 'Completion photos (min 5)', child: SizedBox(
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
                        const SizedBox(height: 6), Text('Add', style: t.bodySmall),
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
          )),
          const SizedBox(height: 6),
          PrimaryButton(label: 'Submit milestone', icon: Icons.lock_outline, loading: _submitting, onPressed: _submit),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
