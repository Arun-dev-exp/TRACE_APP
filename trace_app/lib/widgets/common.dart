import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../models/models.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  const PrimaryButton({super.key, required this.label, this.icon, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon ?? Icons.chevron_right, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: t.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets padding;
  const SectionCard({super.key, this.title, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: t.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(title!, style: t.titleMedium),
          ),
          child,
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

Color statusColor(String s, BuildContext ctx) {
  final t = FlutterFlowTheme.of(ctx);
  switch (s.toLowerCase()) {
    case 'released':
    case 'acted upon':
    case 'approved':
    case 'pass':
      return t.success;
    case 'pending':
    case 'under review':
    case 'received':
    case 'partial':
      return t.warning;
    case 'blocked':
    case 'rejected':
    case 'fail':
      return t.error;
    default: return t.secondaryText;
  }
}

Color schemeColor(SchemeStatus s, BuildContext ctx) {
  final t = FlutterFlowTheme.of(ctx);
  switch (s) {
    case SchemeStatus.green: return t.success;
    case SchemeStatus.yellow: return t.warning;
    case SchemeStatus.red: return t.error;
  }
}

class AlertBanner extends StatelessWidget {
  final String text;
  const AlertBanner({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: t.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.error.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: t.error),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: t.error, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class ImmutabilityDialog extends StatelessWidget {
  final String message;
  const ImmutabilityDialog({super.key, required this.message});
  static Future<bool> show(BuildContext context, {required String message}) async {
    final r = await showDialog<bool>(context: context, builder: (_) => ImmutabilityDialog(message: message));
    return r ?? false;
  }
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(children: [Icon(Icons.lock_outline, color: t.error), const SizedBox(width: 8), const Text('Final submission')]),
      content: Text('$message\n\nThis cannot be edited after submission. It will be recorded permanently on-chain.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: t.primary, foregroundColor: Colors.white),
          child: const Text('Submit permanently'),
        ),
      ],
    );
  }
}
