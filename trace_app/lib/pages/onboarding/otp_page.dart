import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  const OtpPage({super.key, required this.phone});
  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _phoneCtl = TextEditingController();
  final _otpCtl   = TextEditingController();
  bool _sent    = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.phone.isNotEmpty) _phoneCtl.text = widget.phone;
  }

  // ── Send OTP step (UI-only for hackathon — no SMS gateway needed) ─────────
  void _sendOtp() {
    if (_phoneCtl.text.length != 10) {
      _snack('Enter a valid 10-digit mobile number');
      return;
    }
    setState(() => _sent = true);
  }

  // ── Verify OTP + call real backend login ──────────────────────────────────
  Future<void> _verify() async {
    if (_otpCtl.text.length != 6) {
      _snack('OTP must be 6 digits');
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);

    final state = AppState();
    final result = await ApiService.I.login(
      phone: _phoneCtl.text,
      role: state.apiRole,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.ok) {
      _snack('Login failed: ${result.error}');
      return;
    }

    final auth = result.data!;
    // Store phone so profile page can pre-fill
    state.phone = _phoneCtl.text;
    // Store the JWT — ApiService already stored it internally too
    state.token = auth.token;

    context.go('/profile');
  }

  Future<void> _handle() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400)); // small UX delay
    if (!mounted) return;
    if (!_sent) {
      setState(() => _loading = false);
      _sendOtp();
    } else {
      await _verify();
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_sent ? 'Enter the OTP' : 'Log in with phone', style: t.displayLarge),
              const SizedBox(height: 8),
              Text(
                _sent
                    ? 'We sent a 6-digit code to +91 ${_phoneCtl.text}'
                    : 'Only your phone number — no passwords.',
                style: t.bodyMedium.copyWith(color: t.secondaryText),
              ),
              const SizedBox(height: 28),
              if (!_sent)
                TextField(
                  controller: _phoneCtl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    prefixText: '+91  ',
                    hintText: '10-digit mobile number',
                    counterText: '',
                  ),
                ),
              if (_sent)
                TextField(
                  controller: _otpCtl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: const TextStyle(fontSize: 22, letterSpacing: 12, fontWeight: FontWeight.w700),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: '••••••', counterText: ''),
                ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _sent ? 'Verify & continue' : 'Send OTP',
                loading: _loading,
                onPressed: _handle,
              ),
              if (_sent)
                TextButton(
                  onPressed: () => setState(() { _sent = false; _loading = false; _otpCtl.clear(); }),
                  child: const Text('Change number'),
                ),
              if (_sent) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Hackathon build: any 6-digit code works',
                    style: t.bodySmall.copyWith(color: t.secondaryText),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
