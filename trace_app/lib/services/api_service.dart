import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'app_config.dart';

/// All network calls go through this class.
/// Singleton: ApiService.I
///
/// Usage:
///   final result = await ApiService.I.getDistricts();
///   result.fold(onError: (e) => ..., onData: (districts) => ...);
class ApiService {
  ApiService._();
  static final ApiService I = ApiService._();

  String? _token;

  // ── Auth headers ─────────────────────────────────────────────────────────────
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  // ── Low-level helpers ─────────────────────────────────────────────────────────

  Uri _url(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  Future<ApiResult<T>> _get<T>(String path, T Function(dynamic) parse) async {
    try {
      final res = await http.get(_url(path), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handle(res, parse);
    } on SocketException {
      return ApiResult.error('No connection — is the backend running?');
    } on TimeoutException {
      return ApiResult.error('Request timed out');
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  Future<ApiResult<T>> _post<T>(
      String path, Map<String, dynamic> body, T Function(dynamic) parse) async {
    try {
      final res = await http
          .post(_url(path), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      return _handle(res, parse);
    } on SocketException {
      return ApiResult.error('No connection — is the backend running?');
    } on TimeoutException {
      return ApiResult.error('Request timed out');
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  ApiResult<T> _handle<T>(http.Response res, T Function(dynamic) parse) {
    try {
      final body = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResult.ok(parse(body));
      }
      final msg = (body as Map<String, dynamic>)['error'] as String? ?? 'Server error ${res.statusCode}';
      return ApiResult.error(msg);
    } catch (e) {
      return ApiResult.error('Failed to parse response: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Auth
  // ════════════════════════════════════════════════════════════════════════════

  /// POST /api/auth/login
  /// Returns token + user info, stores the token internally.
  Future<ApiResult<AuthResponse>> login({
    required String phone,
    required String role, // 'public' | 'auditor' | 'contractor' | 'admin'
  }) async {
    final result = await _post('/api/auth/login', {'phone': phone, 'role': role},
        (j) => AuthResponse.fromJson(j as Map<String, dynamic>));
    if (result.ok) setToken(result.data!.token);
    return result;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Dashboard / Read endpoints
  // ════════════════════════════════════════════════════════════════════════════

  /// GET /api/districts  — returns all 20 districts sorted by risk_score desc
  Future<ApiResult<List<District>>> getDistricts() =>
      _get('/api/districts', (j) => (j as List).map((d) => District.fromJson(d)).toList());

  /// GET /api/schemes/:districtId
  Future<ApiResult<List<Scheme>>> getSchemes(String districtId) =>
      _get('/api/schemes/$districtId', (d) => (d as List).map((e) => Scheme.fromJson(e)).toList());

  Future<ApiResult<List<Project>>> getProjects(String districtId) =>
      _get('/api/projects/$districtId', (d) => (d as List).map((e) => Project.fromJson(e)).toList());

  /// GET /api/alerts
  Future<ApiResult<List<AlertItem>>> getAlerts() =>
      _get('/api/alerts', (j) => (j as List).map((a) => AlertItem.fromJson(a)).toList());

  /// GET /api/contract/:id
  Future<ApiResult<Contract>> getContract(String id) =>
      _get('/api/contract/$id', (j) => Contract.fromContractJson(j as Map<String, dynamic>));

  /// GET /api/payments/:contractId
  Future<ApiResult<Contract>> getPayments(String contractId) =>
      _get('/api/payments/$contractId', (j) => Contract.fromPaymentsJson(j as Map<String, dynamic>));

  /// GET /api/risk-score/:id?type=project|scheme
  Future<ApiResult<RiskScore>> getRiskScore(String id, {String type = 'project'}) =>
      _get('/api/risk-score/$id?type=$type', (j) => RiskScore.fromJson(j as Map<String, dynamic>));

  /// GET /api/blockchain?limit=50&event_type=freeze
  Future<ApiResult<BlockchainLedger>> getBlockchain({int limit = 50, String? eventType}) {
    final q = eventType != null ? '?limit=$limit&event_type=$eventType' : '?limit=$limit';
    return _get('/api/blockchain$q', (j) => BlockchainLedger.fromJson(j as Map<String, dynamic>));
  }

  /// GET /api/blockchain/:txHash — proof-of-record lookup
  Future<ApiResult<TxRecord>> getTxByHash(String txHash) =>
      _get('/api/blockchain/$txHash', (j) => TxRecord.fromJson(j as Map<String, dynamic>));

  // ════════════════════════════════════════════════════════════════════════════
  // Write endpoints (app actions)
  // ════════════════════════════════════════════════════════════════════════════

  /// POST /api/report — citizen or auditor submits a report
  Future<ApiResult<ReportResponse>> postReport(Report report) =>
      _post('/api/report', report.toJson(),
          (j) => ReportResponse.fromJson(j as Map<String, dynamic>));

  /// POST /api/inspection — auditor submits on-site inspection
  Future<ApiResult<InspectionResponse>> postInspection(Inspection inspection) =>
      _post('/api/inspection', inspection.toJson(),
          (j) => InspectionResponse.fromJson(j as Map<String, dynamic>));

  /// POST /api/invoice — contractor submits material invoice
  Future<ApiResult<InvoiceResponse>> postInvoice({
    required String projectId,
    required String contractorId,
    required String material,
    required double amountCr,
    String invoiceUrl = '',
    String gstNumber = '',
  }) =>
      _post('/api/invoice', {
        'project_id': projectId,
        'contractor_id': contractorId,
        'material': material,
        'amount_cr': amountCr,
        'invoice_url': invoiceUrl,
        'gst_number': gstNumber,
      }, (j) => InvoiceResponse.fromJson(j as Map<String, dynamic>));

  /// POST /api/milestone — contractor submits milestone completion
  Future<ApiResult<MilestoneResponse>> postMilestone({
    required String projectId,
    required int milestone,
    required List<String> photoUrls,
    required double gpsLat,
    required double gpsLng,
    List<String> documents = const [],
  }) =>
      _post('/api/milestone', {
        'project_id': projectId,
        'milestone': milestone,
        'photos': photoUrls,
        'gps_lat': gpsLat,
        'gps_lng': gpsLng,
        'documents': documents,
      }, (j) => MilestoneResponse.fromJson(j as Map<String, dynamic>));
}

// ════════════════════════════════════════════════════════════════════════════
// Result wrapper — no exceptions leak out of ApiService
// ════════════════════════════════════════════════════════════════════════════

class ApiResult<T> {
  final T? data;
  final String? error;
  bool get ok => error == null;

  const ApiResult._({this.data, this.error});
  factory ApiResult.ok(T data) => ApiResult._(data: data);
  factory ApiResult.error(String message) => ApiResult._(error: message);
}

// ════════════════════════════════════════════════════════════════════════════
// Response DTOs
// ════════════════════════════════════════════════════════════════════════════

class AuthResponse {
  final String token;
  final String role;
  final String name;
  final String district;

  const AuthResponse({
    required this.token,
    required this.role,
    required this.name,
    required this.district,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
        token: j['token'] as String,
        role: j['role'] as String,
        name: j['name'] as String,
        district: j['district'] as String,
      );
}

class ReportResponse {
  final String reportId;
  final String status;
  final String message;

  const ReportResponse({required this.reportId, required this.status, required this.message});

  factory ReportResponse.fromJson(Map<String, dynamic> j) => ReportResponse(
        reportId: j['report_id'] as String,
        status: j['status'] as String,
        message: j['message'] as String,
      );
}

class InspectionResponse {
  final String inspectionId;
  final String txHash;
  final String verdict;
  final String paymentAction;

  const InspectionResponse({
    required this.inspectionId,
    required this.txHash,
    required this.verdict,
    required this.paymentAction,
  });

  factory InspectionResponse.fromJson(Map<String, dynamic> j) => InspectionResponse(
        inspectionId: j['inspection_id'] as String,
        txHash: j['tx_hash'] as String,
        verdict: j['verdict'] as String,
        paymentAction: j['payment_action'] as String? ?? '',
      );
}

class InvoiceResponse {
  final String invoiceId;
  final String txHash;
  final String status;

  const InvoiceResponse({required this.invoiceId, required this.txHash, required this.status});

  factory InvoiceResponse.fromJson(Map<String, dynamic> j) => InvoiceResponse(
        invoiceId: j['invoice_id'] as String,
        txHash: j['tx_hash'] as String,
        status: j['status'] as String,
      );
}

class MilestoneResponse {
  final String submissionId;
  final int milestone;
  final String status;
  final String message;

  const MilestoneResponse({
    required this.submissionId,
    required this.milestone,
    required this.status,
    required this.message,
  });

  factory MilestoneResponse.fromJson(Map<String, dynamic> j) => MilestoneResponse(
        submissionId: j['submission_id'] as String,
        milestone: (j['milestone'] as num).toInt(),
        status: j['status'] as String,
        message: j['message'] as String,
      );
}

class AlertItem {
  final String id;
  final String type;
  final String title;
  final String description;
  final String district;
  final int riskScore;
  final String status;

  const AlertItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.district,
    required this.riskScore,
    required this.status,
  });

  factory AlertItem.fromJson(Map<String, dynamic> j) => AlertItem(
        id: j['id'] as String,
        type: j['type'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        district: j['district'] as String? ?? '',
        riskScore: (j['risk_score'] as num).toInt(),
        status: j['status'] as String,
      );
}

class RiskScore {
  final int total;
  final String riskLevel;
  final List<String> flags;
  final Map<String, int> breakdown;

  const RiskScore({
    required this.total,
    required this.riskLevel,
    required this.flags,
    required this.breakdown,
  });

  factory RiskScore.fromJson(Map<String, dynamic> j) => RiskScore(
        total: (j['total_score'] as num? ?? j['risk_score'] as num? ?? 0).toInt(),
        riskLevel: j['risk_level'] as String? ?? 'unknown',
        flags: (j['flags'] as List<dynamic>?)?.cast<String>() ?? [],
        breakdown: (j['breakdown'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
            {},
      );
}

class TimeoutException implements Exception {
  const TimeoutException();
}

// ════════════════════════════════════════════════════════════════════════════
// Blockchain DTOs
// ════════════════════════════════════════════════════════════════════════════

class TxRecord {
  final String txHash;
  final String eventType;   // 'freeze' | 'allocate' | 'flag' | 'report'
  final String entityId;
  final String entityType;
  final double amountCr;
  final String? location;
  final String? district;
  final String? state;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final bool immutable;
  final bool verified;

  const TxRecord({
    required this.txHash,
    required this.eventType,
    required this.entityId,
    required this.entityType,
    required this.amountCr,
    required this.timestamp,
    this.location,
    this.district,
    this.state,
    this.metadata = const {},
    this.immutable = true,
    this.verified = true,
  });

  factory TxRecord.fromJson(Map<String, dynamic> j) => TxRecord(
        txHash:     j['tx_hash'] as String,
        eventType:  j['event_type'] as String,
        entityId:   j['entity_id'] as String,
        entityType: j['entity_type'] as String,
        amountCr:   (j['amount_cr'] as num? ?? 0).toDouble(),
        location:   j['location'] as String?,
        district:   j['district'] as String?,
        state:      j['state'] as String?,
        timestamp:  DateTime.parse(j['timestamp'] as String),
        metadata:   (j['metadata'] as Map<String, dynamic>?) ?? {},
        immutable:  j['immutable'] as bool? ?? true,
        verified:   j['verified'] as bool? ?? true,
      );
}

class BlockchainLedger {
  final int total;
  final List<TxRecord> ledger;

  const BlockchainLedger({required this.total, required this.ledger});

  factory BlockchainLedger.fromJson(Map<String, dynamic> j) => BlockchainLedger(
        total: (j['total'] as num).toInt(),
        ledger: (j['ledger'] as List<dynamic>)
            .map((t) => TxRecord.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

