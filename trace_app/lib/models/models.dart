// ─── Enums ──────────────────────────────────────────────────────────────────

enum UserRole { none, citizen, auditor, contractor }
enum SchemeStatus { green, yellow, red }

// ─── District ───────────────────────────────────────────────────────────────

class District {
  final String id;
  final String name;
  final String state;
  final int riskScore;
  final String status; // 'clean' | 'watch' | 'flagged'
  final double lat;
  final double lng;
  final double missingCrore;

  const District({
    required this.id,
    required this.name,
    required this.state,
    required this.riskScore,
    required this.status,
    required this.lat,
    required this.lng,
    required this.missingCrore,
  });

  factory District.fromJson(Map<String, dynamic> j) => District(
        id: j['id'] as String,
        name: j['name'] as String,
        state: j['state'] as String,
        riskScore: (j['risk_score'] as num).toInt(),
        status: j['status'] as String,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        missingCrore: (j['missing_crore'] as num? ?? 0).toDouble(),
      );
}

// ─── Project (used by auditor & citizen) ────────────────────────────────────

class Project {
  final String id;
  final String name;
  final String contractor;
  final String milestone; // current milestone description
  final double lat;
  final double lng;
  final bool flagged;
  final String districtId;
  final String districtName;

  const Project({
    required this.id,
    required this.name,
    required this.contractor,
    required this.milestone,
    required this.lat,
    required this.lng,
    required this.districtId,
    this.districtName = '',
    this.flagged = false,
  });

  /// Created from GET /api/districts-level projects list or /api/contract/:id
  factory Project.fromJson(Map<String, dynamic> j) => Project(
        id: j['id'] as String,
        name: j['name'] as String,
        contractor: j['contractor_name'] as String? ?? '',
        milestone: 'Milestone ${j['phase'] ?? 1}',
        lat: (j['lat'] as num? ?? 0).toDouble(),
        lng: (j['lng'] as num? ?? 0).toDouble(),
        flagged: j['status'] == 'flagged' || j['phase2_frozen'] == true,
        districtId: j['district_id'] as String? ?? '',
        districtName: (j['districts'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      );
}

// ─── Scheme ──────────────────────────────────────────────────────────────────

class Scheme {
  final String id;
  final String name;
  final double allocated;
  final double withdrawn;
  final double returned;
  final double missingCrore;
  final double returnRate;
  final int riskScore;
  final String status;
  final int beneficiaryCount;

  const Scheme({
    required this.id,
    required this.name,
    required this.allocated,
    required this.withdrawn,
    required this.returned,
    required this.missingCrore,
    required this.returnRate,
    required this.riskScore,
    required this.status,
    required this.beneficiaryCount,
  });

  SchemeStatus get schemeStatus {
    if (riskScore > 65) return SchemeStatus.red;
    if (riskScore > 35) return SchemeStatus.yellow;
    return SchemeStatus.green;
  }

  factory Scheme.fromJson(Map<String, dynamic> j) => Scheme(
        id: j['id'] as String,
        name: j['name'] as String,
        allocated: (j['allocated_crore'] as num).toDouble(),
        withdrawn: (j['withdrawn_crore'] as num).toDouble(),
        returned: (j['returned_crore'] as num).toDouble(),
        missingCrore: (j['missing_crore'] as num? ?? 0).toDouble(),
        returnRate: (j['return_rate'] as num? ?? 0).toDouble(),
        riskScore: (j['risk_score'] as num).toInt(),
        status: j['status'] as String,
        beneficiaryCount: (j['beneficiary_count'] as num? ?? 0).toInt(),
      );
}

// ─── Report (citizen submission) ─────────────────────────────────────────────

class Report {
  final String? id;
  final String type;         // 'citizen'
  final String category;     // 'road_quality' | 'ghost_project' | 'suspicious_activity' | 'other'
  final String description;
  final String photoUrl;     // local path before upload; URL after
  final double lat;
  final double lng;
  final String districtId;   // required by backend
  final String? projectId;
  final String status;
  final DateTime createdAt;

  const Report({
    this.id,
    required this.type,
    required this.category,
    required this.description,
    required this.photoUrl,
    required this.lat,
    required this.lng,
    required this.districtId,
    this.projectId,
    this.status = 'Received',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? const _Now();

  Report copyWith({String? id, String? status}) => Report(
        id: id ?? this.id,
        type: type,
        category: category,
        description: description,
        photoUrl: photoUrl,
        lat: lat,
        lng: lng,
        districtId: districtId,
        projectId: projectId,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'category': category,
        'description': description,
        'photo_url': photoUrl,
        'gps_lat': lat,
        'gps_lng': lng,
        'district_id': districtId,
        if (projectId != null) 'project_id': projectId,
        'submitted_by': type,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  factory Report.fromJson(Map<String, dynamic> j) => Report(
        id: j['id'] as String?,
        type: j['type'] as String? ?? 'citizen',
        category: j['category'] as String? ?? 'other',
        description: j['description'] as String? ?? '',
        photoUrl: j['photo_url'] as String? ?? '',
        lat: (j['gps_lat'] as num?)?.toDouble() ?? 0.0,
        lng: (j['gps_lng'] as num?)?.toDouble() ?? 0.0,
        districtId: j['district_id'] as String? ?? '',
        projectId: j['project_id'] as String?,
        status: j['status'] as String? ?? 'Received',
        createdAt: j['created_at'] != null ? DateTime.parse(j['created_at'] as String) : null,
      );
}

// Helper: DateTime.now() can't be used as a default const value
class _Now implements DateTime {
  const _Now();
  @override dynamic noSuchMethod(Invocation i) => DateTime.now();
}

// ─── Inspection (auditor submission) ─────────────────────────────────────────

class ChecklistItem {
  final String label;
  final String key;   // snake_case key sent to backend e.g. 'road_width'
  String result;      // 'pass' | 'fail' | 'partial'

  ChecklistItem(this.label, this.key, [this.result = 'pass']);
}

class Inspection {
  final String? id;
  final String projectId;
  final String auditorId;
  final double gpsLat;
  final double gpsLng;
  final List<String> photoUrls;
  final Map<String, String> checklist; // { 'road_width': 'pass', ... }
  final String verdict; // 'approved' | 'rejected' | 'needs_reinspection'
  final String notes;
  final int failedItems;
  final DateTime createdAt;

  const Inspection({
    this.id,
    required this.projectId,
    required this.auditorId,
    required this.gpsLat,
    required this.gpsLng,
    required this.photoUrls,
    required this.checklist,
    required this.verdict,
    required this.notes,
    required this.failedItems,
    required this.createdAt,
  });

  Inspection copyWith({String? id}) => Inspection(
        id: id ?? this.id,
        projectId: projectId,
        auditorId: auditorId,
        gpsLat: gpsLat,
        gpsLng: gpsLng,
        photoUrls: photoUrls,
        checklist: checklist,
        verdict: verdict,
        notes: notes,
        failedItems: failedItems,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'auditor_id': auditorId,
        'gps_lat': gpsLat,
        'gps_lng': gpsLng,
        'photos': photoUrls,
        'checklist': checklist,
        'verdict': verdict,
        'notes': notes,
      };
}

// ─── Milestone / Payment ─────────────────────────────────────────────────────

class Milestone {
  final int index;
  final double amount;  // ₹ crore
  final String status;  // 'released' | 'pending' | 'blocked'
  final String? blockReason;
  final DateTime? releasedAt;
  final DateTime? expectedDate;

  const Milestone({
    required this.index,
    required this.amount,
    required this.status,
    this.blockReason,
    this.releasedAt,
    this.expectedDate,
  });

  factory Milestone.fromJson(Map<String, dynamic> j) => Milestone(
        index: (j['milestone'] as num).toInt(),
        amount: (j['amount_cr'] as num).toDouble(),
        status: _capitalise(j['status'] as String),
        blockReason: j['block_reason'] as String?,
        releasedAt: j['released_at'] != null ? DateTime.tryParse(j['released_at'] as String) : null,
        expectedDate: j['expected_date'] != null ? DateTime.tryParse(j['expected_date'] as String) : null,
      );

  static String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class Contract {
  final String id;
  final String name;
  final String contractorName;
  final double totalValueCr;
  final int riskScore;
  final bool phase2Frozen;
  final List<Milestone> milestones;

  const Contract({
    required this.id,
    required this.name,
    required this.contractorName,
    required this.totalValueCr,
    required this.riskScore,
    required this.phase2Frozen,
    required this.milestones,
  });

  factory Contract.fromPaymentsJson(Map<String, dynamic> j) => Contract(
        id: j['contract_id'] as String,
        name: '', // not returned by /api/payments
        contractorName: j['contractor'] as String? ?? '',
        totalValueCr: (j['total_value_cr'] as num).toDouble(),
        riskScore: 0,
        phase2Frozen: (j['milestones'] as List<dynamic>).any(
          (m) => m['status'] == 'blocked',
        ),
        milestones: (j['milestones'] as List<dynamic>)
            .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  factory Contract.fromContractJson(Map<String, dynamic> j) => Contract(
        id: j['id'] as String,
        name: j['name'] as String,
        contractorName: j['contractor_name'] as String? ?? '',
        totalValueCr: (j['contract_value_cr'] as num).toDouble(),
        riskScore: (j['risk_score'] as num).toInt(),
        phase2Frozen: j['phase2_frozen'] as bool? ?? false,
        milestones: (j['payments'] as List<dynamic>? ?? [])
            .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}
