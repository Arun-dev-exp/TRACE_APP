enum SchemeStatus { green, yellow, red }

class Project {
  final String id, name, contractor, milestone;
  final double lat, lng;
  final bool flagged;
  Project({required this.id, required this.name, required this.contractor,
      required this.milestone, required this.lat, required this.lng, this.flagged = false});
}

class Scheme {
  final String name;
  final double allocated, returned;
  final SchemeStatus status;
  final int beneficiaries;
  Scheme({required this.name, required this.allocated, required this.returned,
      required this.status, required this.beneficiaries});
}

class Report {
  final String? id;
  final String category, description, photoPath;
  final double lat, lng;
  final String? projectId;
  final String status;
  final DateTime createdAt;
  Report({this.id, required this.category, required this.description, required this.photoPath,
      required this.lat, required this.lng, this.projectId, this.status = 'Received',
      DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();
  Report copyWith({String? id, String? status}) => Report(
    id: id ?? this.id, category: category, description: description, photoPath: photoPath,
    lat: lat, lng: lng, projectId: projectId, status: status ?? this.status, createdAt: createdAt);
}

class ChecklistItem {
  final String label;
  String result; // Pass/Fail/Partial
  ChecklistItem(this.label, [this.result = 'Pass']);
}

class Inspection {
  final String? id;
  final String projectId, verdict;
  final int failedItems;
  final DateTime createdAt;
  Inspection({this.id, required this.projectId, required this.verdict,
      required this.failedItems, required this.createdAt});
  Inspection copyWith({String? id}) => Inspection(
      id: id ?? this.id, projectId: projectId, verdict: verdict,
      failedItems: failedItems, createdAt: createdAt);
}

class Milestone {
  final int index;
  final double amount; // ₹ crore
  final String status; // Released / Pending / Blocked
  final String? blockReason;
  final DateTime? releasedAt;
  Milestone({required this.index, required this.amount, required this.status,
      this.blockReason, this.releasedAt});
}

class Contract {
  final String id, name;
  final int riskScore;
  final List<Milestone> milestones;
  Contract({required this.id, required this.name, required this.riskScore, required this.milestones});
}
