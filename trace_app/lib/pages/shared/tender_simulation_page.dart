import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../services/tender_simulation_service.dart';

class TenderSimulationPage extends StatefulWidget {
  const TenderSimulationPage({super.key});

  @override
  State<TenderSimulationPage> createState() => _TenderSimulationPageState();
}

class _TenderSimulationPageState extends State<TenderSimulationPage> {
  final TenderSimulationService _service = TenderSimulationService();
  late List<Bidder> _bidders;
  
  int _currentPhase = 0; // 0: Init, 1: Benchmark, 2: Evaluating, 3: Awarded
  Bidder? _winner;

  @override
  void initState() {
    super.initState();
    _bidders = _service.getBidders();
  }

  void _startSimulation() async {
    setState(() => _currentPhase = 1);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    setState(() => _currentPhase = 2);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    
    _service.evaluateBidders(_bidders);
    _winner = _service.getWinner(_bidders);
    setState(() => _currentPhase = 3);
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final proj = _service.project;

    return Scaffold(
      backgroundColor: t.primaryBackground,
      appBar: AppBar(
        title: const Text('Smart Governance AI'),
        centerTitle: true,
        backgroundColor: t.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Context
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tender Subject', style: t.bodyMedium),
                  const SizedBox(height: 4),
                  Text(proj.title, style: t.titleMedium.copyWith(color: t.primary)),
                  const SizedBox(height: 8),
                  Text(proj.description, style: t.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Action / Phases
            if (_currentPhase == 0)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _startSimulation,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Initialize AI Allocation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            if (_currentPhase >= 1) ...[
              // Phase 1: Benchmark
              _buildPhaseHeader('1. AI Cost Benchmarking', isActive: _currentPhase == 1, isDone: _currentPhase > 1, t: t),
              if (_currentPhase == 1) const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
              if (_currentPhase > 1) 
                Container(
                  margin: const EdgeInsets.only(left: 16, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: t.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: t.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI Benchmark established at ₹${proj.benchmarkLowCr}Cr - ₹${proj.benchmarkHighCr}Cr', style: t.bodyMedium)),
                    ],
                  ),
                ),

              // Phase 2: Evaluation
              _buildPhaseHeader('2. Contractor Evaluation', isActive: _currentPhase == 2, isDone: _currentPhase > 2, t: t),
              if (_currentPhase == 2) const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
              if (_currentPhase >= 2) ...[
                const SizedBox(height: 8),
                ..._bidders.map((b) => _buildBidderCard(b, t, showResult: _currentPhase == 3)),
                const SizedBox(height: 16),
              ],

              // Phase 3: Award
              if (_currentPhase == 3) ...[
                _buildPhaseHeader('3. Tender Awarded', isActive: true, isDone: false, t: t),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [t.success, Colors.green.shade700]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
                      const SizedBox(height: 12),
                      Text('Contract Awarded to', style: t.titleMedium.copyWith(color: Colors.white70)),
                      Text(_winner?.name ?? 'No Suitable Bidder', style: t.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Bid: ₹${_winner?.bidAmountCr}Cr (Optimal range)\nSuccess Rate: ${((_winner?.pastDeliverySuccessRate ?? 0) * 100).toInt()}%', 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ]
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseHeader(String title, {required bool isActive, required bool isDone, required FlutterFlowTheme t}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : (isActive ? Icons.sync : Icons.radio_button_unchecked),
              color: isDone ? t.success : (isActive ? t.primary : t.secondaryText)),
          const SizedBox(width: 8),
          Text(title, style: t.titleMedium.copyWith(
            color: isActive || isDone ? t.primaryText : t.secondaryText,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          )),
        ],
      ),
    );
  }

  Widget _buildBidderCard(Bidder b, FlutterFlowTheme t, {required bool showResult}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: showResult ? (b.rejected ? t.error.withOpacity(0.05) : t.success.withOpacity(0.05)) : Colors.white,
        border: Border.all(color: showResult ? (b.rejected ? t.error.withOpacity(0.3) : t.success.withOpacity(0.3)) : t.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(b.name, style: t.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text('₹${b.bidAmountCr}Cr', style: t.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          if (showResult && b.rejected) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.cancel, size: 14, color: t.error),
                const SizedBox(width: 4),
                Expanded(child: Text(b.rejectionReason, style: t.bodySmall.copyWith(color: t.error))),
              ],
            )
          ] else if (showResult && !b.rejected) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: t.success),
                const SizedBox(width: 4),
                Expanded(child: Text('Approved (Score: ${b.score.toStringAsFixed(1)})', style: t.bodySmall.copyWith(color: t.success))),
              ],
            )
          ]
        ],
      ),
    );
  }
}
