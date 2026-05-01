import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});
  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final _ctrl = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onDetect(BarcodeCapture cap) {
    if (_handled) return;
    final code = cap.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    _handled = true;
    // Accept either a known project ID or any QR — fall back to first project
    final match = MockApi.I.projects.any((p) => p.id == code)
        ? code : MockApi.I.projects.first.id;
    context.pushReplacement('/auditor/inspect?pid=$match');
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scan project QR'),
      ),
      body: Stack(children: [
        MobileScanner(controller: _ctrl, onDetect: _onDetect),
        Center(child: Container(
          width: 260, height: 260,
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(20)),
        )),
        Positioned(
          left: 0, right: 0, bottom: 40,
          child: Column(children: [
            const Text('Align the QR within the box', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _handled = true;
                context.pushReplacement('/auditor/inspect?pid=${MockApi.I.projects.first.id}');
              },
              child: Text('Simulate scan (demo)', style: TextStyle(color: t.tertiary)),
            ),
          ]),
        ),
      ]),
    );
  }
}
