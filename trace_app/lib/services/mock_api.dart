import 'dart:math';
import '../models/models.dart';

/// Stub service standing in for the 7 endpoints in the PRD.
/// Swap the bodies with real HTTP calls when backend is ready.
class MockApi {
  static final MockApi I = MockApi._();
  MockApi._();

  final _rand = Random();

  final List<Project> projects = [
    Project(id: 'JHS-RD-017', name: 'Jhansi-Orchha Road Widening', contractor: 'Bharat Infra Ltd',
        milestone: 'Milestone 2 — Base layer', lat: 25.4484, lng: 78.5685, flagged: true),
    Project(id: 'JHS-WT-008', name: 'Jhansi Water Supply Phase II', contractor: 'Nirmal Jal Pvt',
        milestone: 'Milestone 1 — Excavation', lat: 25.4601, lng: 78.5772, flagged: false),
    Project(id: 'JHS-SC-003', name: 'Primary School Block, Babina', contractor: 'Sri Vinayak Constr.',
        milestone: 'Milestone 3 — Roofing', lat: 25.3150, lng: 78.4711, flagged: false),
  ];

  final List<Scheme> schemes = [
    Scheme(name: 'PMGSY — Rural Roads', allocated: 420, returned: 38, status: SchemeStatus.green, beneficiaries: 14200),
    Scheme(name: 'Jal Jeevan Mission', allocated: 310, returned: 92, status: SchemeStatus.yellow, beneficiaries: 21000),
    Scheme(name: 'Samagra Shiksha', allocated: 180, returned: 110, status: SchemeStatus.red, beneficiaries: 8400),
  ];

  final List<Report> myReports = [];
  final List<Inspection> inspections = [
    Inspection(id: 'INS-0421', projectId: 'JHS-RD-017', verdict: 'Rejected',
        failedItems: 2, createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  final List<Contract> contracts = [
    Contract(id: 'JHS-RD-017', name: 'Jhansi-Orchha Road Widening', riskScore: 72,
        milestones: [
          Milestone(index: 1, amount: 1.2, status: 'Released', releasedAt: DateTime(2026, 2, 10)),
          Milestone(index: 2, amount: 1.5, status: 'Blocked', blockReason: 'Inspection failed: base layer thickness below spec'),
          Milestone(index: 3, amount: 1.8, status: 'Pending'),
          Milestone(index: 4, amount: 0.9, status: 'Pending'),
        ]),
  ];

  // Endpoints -----------------------------------------------------------------
  Future<String> postReport(Report r) async {
    await _delay();
    final id = 'RPT-${_rand.nextInt(9000) + 1000}';
    myReports.insert(0, r.copyWith(id: id, status: 'Received'));
    return id;
  }

  Future<String> postInspection(Inspection i) async {
    await _delay();
    final id = 'INS-${_rand.nextInt(9000) + 1000}';
    inspections.insert(0, i.copyWith(id: id));
    return id;
  }

  Future<String> postInvoice(String contractId, String material, double amount) async {
    await _delay();
    return 'INV-${_rand.nextInt(9000) + 1000}';
  }

  Future<String> postMilestone(String contractId, int milestone) async {
    await _delay();
    return 'MS-${_rand.nextInt(9000) + 1000}';
  }

  Future<List<Scheme>> getSchemes(String district) async { await _delay(); return schemes; }
  Future<Contract> getPayments(String contractId) async {
    await _delay();
    return contracts.firstWhere((c) => c.id == contractId, orElse: () => contracts.first);
  }
  Future<int> getRiskScore(String contractorId) async { await _delay(); return 72; }

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 600));
}
