import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/mock_api.dart';
import '../../widgets/common.dart';

class SubmitInvoicePage extends StatefulWidget {
  const SubmitInvoicePage({super.key});
  @override
  State<SubmitInvoicePage> createState() => _SubmitInvoicePageState();
}

class _SubmitInvoicePageState extends State<SubmitInvoicePage> {
  String _contract = 'JHS-RD-017';
  String _material = 'Cement (OPC 53)';
  final _amount = TextEditingController();
  XFile? _photo;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Submit invoice')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(title: 'Contract', child: DropdownButtonFormField<String>(
            value: _contract,
            items: MockApi.I.contracts.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.id} — ${c.name}'))).toList(),
            onChanged: (v) => setState(() => _contract = v!),
          )),
          SectionCard(title: 'Material', child: DropdownButtonFormField<String>(
            value: _material,
            items: const [
              'Cement (OPC 53)', 'Steel rebar', 'Bitumen', 'Aggregate', 'Concrete blocks'
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _material = v!),
          )),
          SectionCard(title: 'GST invoice photo', child: GestureDetector(
            onTap: () async {
              final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 82);
              if (p != null) setState(() => _photo = p);
            },
            child: Container(
              height: 160,
              decoration: BoxDecoration(color: t.primaryBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: t.divider)),
              child: _photo == null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.upload_file, size: 36, color: t.secondaryText),
                      const SizedBox(height: 6),
                      Text('Tap to upload invoice', style: t.bodyMedium.copyWith(color: t.secondaryText)),
                    ]))
                  : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_photo!.path), fit: BoxFit.cover, width: double.infinity)),
            ),
          )),
          SectionCard(title: 'Amount (₹) — OCR is roadmap, enter manually', child: TextField(
            controller: _amount, keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(prefixText: '₹  ', hintText: '0'),
          )),
          const SizedBox(height: 6),
          PrimaryButton(label: 'Submit invoice', icon: Icons.send_rounded, loading: _submitting, onPressed: () async {
            if (_photo == null) { _snack('Upload the invoice photo'); return; }
            if ((_amount.text).isEmpty) { _snack('Enter amount'); return; }
            setState(() => _submitting = true);
            final id = await MockApi.I.postInvoice(_contract, _material, double.tryParse(_amount.text) ?? 0);
            setState(() => _submitting = false);
            if (!mounted) return;
            _snack('Invoice $id linked to $_contract');
            context.pop();
          }),
        ],
      ),
    );
  }
  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}
