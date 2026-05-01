import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../widgets/common.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});
  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _name = TextEditingController();
  final _district = TextEditingController(text: 'Jhansi');
  final _aadhaar = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final role = AppState().role;
    final requireAadhaar = role == UserRole.auditor || role == UserRole.contractor;
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Just once. Then you\'re in.', style: t.bodyMedium.copyWith(color: t.secondaryText)),
            const SizedBox(height: 20),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 12),
            TextField(controller: _district, decoration: const InputDecoration(labelText: 'District')),
            if (requireAadhaar) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _aadhaar,
                maxLength: 4,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Last 4 of Aadhaar', counterText: ''),
              ),
            ],
            const Spacer(),
            PrimaryButton(label: 'Continue', onPressed: () {
              if (_name.text.trim().isEmpty || _district.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
                return;
              }
              if (requireAadhaar && _aadhaar.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter last 4 of Aadhaar')));
                return;
              }
              AppState().setProfile(n: _name.text.trim(), d: _district.text.trim(), a: _aadhaar.text);
              switch (role) {
                case UserRole.citizen: context.go('/citizen'); break;
                case UserRole.auditor: context.go('/auditor'); break;
                case UserRole.contractor: context.go('/contractor'); break;
                default: context.go('/role');
              }
            }),
          ]),
        ),
      ),
    );
  }
}
