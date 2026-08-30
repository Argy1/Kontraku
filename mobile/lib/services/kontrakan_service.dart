import 'package:dio/dio.dart';

import '../models/models.dart';
import 'api_client.dart';

/// Semua panggilan API untuk domain properti: kontrakan, unit, penyewa,
/// pembayaran, dan dokumen.
class KontrakanService {
  KontrakanService(this._api);

  final ApiClient _api;

  // --- Kontrakan ---------------------------------------------------------

  Future<List<Kontrakan>> list() async {
    final data = await _api.get('/kontrakan') as List;
    return data
        .map((e) => Kontrakan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<KontrakanDetail> detail(int id) async {
    final data = await _api.get('/kontrakan/$id');
    return KontrakanDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<Kontrakan> create({
    required String name,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final data = await _api.post('/kontrakan', body: {
      'name': name,
      if (address != null && address.isNotEmpty) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    return Kontrakan.fromJson(data as Map<String, dynamic>);
  }

  Future<Kontrakan> update(
    int id, {
    String? name,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final data = await _api.patch('/kontrakan/$id', body: {
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    return Kontrakan.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/kontrakan/$id');

  // --- Unit ------------------------------------------------------------

  Future<Unit> createUnit(
    int kontrakanId, {
    required String name,
    required UnitStatus status,
    double? price,
  }) async {
    final data = await _api.post('/kontrakan/$kontrakanId/units', body: {
      'name': name,
      'status': status.api,
      if (price != null) 'price': price,
    });
    return Unit.fromJson(data as Map<String, dynamic>);
  }

  Future<Unit> updateUnit(
    int unitId, {
    String? name,
    UnitStatus? status,
    double? price,
  }) async {
    final data = await _api.patch('/units/$unitId', body: {
      if (name != null) 'name': name,
      if (status != null) 'status': status.api,
      if (price != null) 'price': price,
    });
    return Unit.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteUnit(int unitId) => _api.delete('/units/$unitId');

  // --- Penyewa --------------------------------------------------------

  Future<List<Tenant>> tenants(int unitId, {bool includeInactive = false}) async {
    final data = await _api.get(
      '/units/$unitId/tenants',
      query: {if (includeInactive) 'include_inactive': true},
    ) as List;
    return data.map((e) => Tenant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Tenant> createTenant(
    int unitId, {
    required String name,
    String? phone,
    DateTime? contractStart,
    DateTime? contractEnd,
    double? rentAmount,
    int? dueDay,
  }) async {
    final data = await _api.post('/units/$unitId/tenants', body: {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (contractStart != null) 'contract_start': _date(contractStart),
      if (contractEnd != null) 'contract_end': _date(contractEnd),
      if (rentAmount != null) 'rent_amount': rentAmount,
      if (dueDay != null) 'due_day': dueDay,
    });
    return Tenant.fromJson(data as Map<String, dynamic>);
  }

  Future<Tenant> updateTenant(
    int tenantId, {
    String? name,
    String? phone,
    DateTime? contractStart,
    DateTime? contractEnd,
    double? rentAmount,
    int? dueDay,
    bool clearDueDay = false,
    bool clearContractEnd = false,
  }) async {
    final data = await _api.patch('/tenants/$tenantId', body: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (contractStart != null) 'contract_start': _date(contractStart),
      if (contractEnd != null) 'contract_end': _date(contractEnd),
      if (clearContractEnd) 'contract_end': null,
      if (rentAmount != null) 'rent_amount': rentAmount,
      if (dueDay != null) 'due_day': dueDay,
      if (clearDueDay) 'due_day': null,
    });
    return Tenant.fromJson(data as Map<String, dynamic>);
  }

  Future<Tenant> archiveTenant(int tenantId) async {
    final data = await _api.post('/tenants/$tenantId/archive');
    return Tenant.fromJson(data as Map<String, dynamic>);
  }

  // --- Pembayaran ----------------------------------------------------

  Future<List<Payment>> payments(int tenantId) async {
    final data = await _api.get('/tenants/$tenantId/payments') as List;
    return data.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Payment> createPayment(
    int tenantId, {
    required double amount,
    required DateTime paidDate,
    DateTime? periodStart,
    String? note,
  }) async {
    final data = await _api.post('/tenants/$tenantId/payments', body: {
      'amount': amount,
      'paid_date': _date(paidDate),
      if (periodStart != null) 'period_start': _date(periodStart),
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return Payment.fromJson(data as Map<String, dynamic>);
  }

  // --- Dokumen / foto -----------------------------------------------

  Future<DocumentItem> uploadDocument(
    int kontrakanId, {
    required List<int> bytes,
    required String filename,
    required DocumentType type,
    String? label,
  }) async {
    final data = await _api.post(
      '/kontrakan/$kontrakanId/documents',
      body: FormData.fromMap({
        'type': type.api,
        if (label != null && label.isNotEmpty) 'label': label,
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    );
    return DocumentItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteDocument(int kontrakanId, int documentId) =>
      _api.delete('/kontrakan/$kontrakanId/documents/$documentId');

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
