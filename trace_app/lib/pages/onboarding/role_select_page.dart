import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final roles = [
      _RoleData('Citizen', 'Report issues, track schemes', Icons.person_outline, UserRole.citizen),
      _RoleData('Field Auditor', 'Inspect projects on-site', Icons.verified_user_outlined, UserRole.auditor),
      _RoleData('Contractor', 'Submit proofs & track payments', Icons.engineering_outlined, UserRole.contractor),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text('Who are you?', style: t.displayLarge),
              const SizedBox(height: 8),
              Text('Your role decides what you can do in TRACE.', style: t.bodyMedium.copyWith(color: t.secondaryText)),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => _RoleTile(data: roles[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleData {
  final String title, subtitle;
  final IconData icon;
  final UserRole role;
  _RoleData(this.title, this.subtitle, this.icon, this.role);
}

class _RoleTile extends StatelessWidget {
  final _RoleData data;
  const _RoleTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Material(
      color: t.secondaryBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          AppState().setRole(data.role);
          context.push('/otp?phone=');
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.divider),
          ),
          child: Row(children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(color: t.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
              child: Icon(data.icon, color: t.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data.title, style: t.headlineSmall),
              const SizedBox(height: 4),
              Text(data.subtitle, style: t.bodySmall),
            ])),
            Icon(Icons.arrow_forward_ios, color: t.secondaryText, size: 16),
          ]),
        ),
      ),
    );
  }
}
