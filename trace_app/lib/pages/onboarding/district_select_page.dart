import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';

class DistrictSelectPage extends StatefulWidget {
  const DistrictSelectPage({super.key});
  @override
  State<DistrictSelectPage> createState() => _DistrictSelectPageState();
}

class _DistrictSelectPageState extends State<DistrictSelectPage> {
  List<District> _districts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    setState(() { _loading = true; _error = null; });
    final res = await ApiService.I.getDistricts();
    if (!mounted) return;
    if (res.ok) {
      setState(() {
        _districts = res.data!;
        // Sort alphabetically
        _districts.sort((a, b) => a.name.compareTo(b.name));
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.error;
        _loading = false;
      });
    }
  }

  Future<void> _selectDistrict(District d) async {
    await AppState().setDistrict(d.name, d.id);
    if (!mounted) return;
    context.go('/citizen');
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: AppBar(
        title: const Text('Select Your District'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.error_outline, size: 48, color: t.error),
                    const SizedBox(height: 16),
                    Text(_error!, style: t.bodyMedium),
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'Retry', onPressed: _loadDistricts),
                  ]),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _districts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final d = _districts[index];
                    return InkWell(
                      onTap: () => _selectDistrict(d),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: t.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(d.name, style: t.titleMedium),
                            Icon(Icons.chevron_right, color: t.secondaryText),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
