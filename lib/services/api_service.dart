import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

/// Thrown when the VIPS backend rejects or fails to serve a request.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin client around the VIPS D190 low-code backend.
///
/// Every MySQL table is exposed as a generic CRUD resource identified by a
/// numeric table id (see [ApiConstants]). There is no custom business logic
/// on the server, so all app behaviour (auth checks, grading, aggregation)
/// happens in the Flutter layer through the repositories built on top of
/// this service.
///
/// Endpoint convention, confirmed against a working reference client for
/// this same VIPS backend:
///   GET  /api/{connId}/{databaseId}/{tableId}      -> list (supports
///                                                     `?column=value`
///                                                     filtering)
///   POST /api-in/{connId}/{databaseId}/{tableId}    -> create, multipart
///                                                     form fields, id comes
///                                                     back as `lastInsertId`
///                                                     (or `id`)
///   POST /api-up/{connId}/{databaseId}/{tableId}    -> update, multipart
///                                                     form fields plus a
///                                                     `where: "id:<id>"`
///                                                     field
///   GET  /api-del/{connId}/{databaseId}/{tableId}   -> delete, `?id=<id>`
class ApiService {
  ApiService._();

  static Map<String, String> get _headers => {'VIPS-API-Key': ApiConstants.apiKey};

  static Uri _uri(String endpoint, String tableId, [Map<String, dynamic>? query]) {
    final path = '$endpoint/${ApiConstants.connId}/${ApiConstants.databaseId}/$tableId';
    final stringQuery = query?.map((key, value) => MapEntry(key, value.toString()));
    return Uri.parse('${ApiConstants.baseUrl}/$path').replace(queryParameters: stringQuery);
  }

  static Map<String, String> _toFields(Map<String, dynamic> map) {
    return map.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  static dynamic _decode(http.Response res) {
    if (res.body.isEmpty) return null;
    try {
      return jsonDecode(res.body);
    } on FormatException {
      return null;
    }
  }

  static bool _isSuccess(dynamic decoded) {
    if (decoded is! Map) return false;
    if (decoded['success'] == 1 || decoded['success'] == true) return true;
    return decoded['status'] == 'success' || decoded['status'] == 'ok';
  }

  static Future<Map<String, dynamic>> _postForm(Uri uri, Map<String, String> fields) async {
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers)
      ..fields.addAll(fields);
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('So\'rovda xatolik', statusCode: res.statusCode);
    }

    final decoded = _decode(res);
    return decoded is Map ? decoded.cast<String, dynamic>() : {};
  }

  /// Fetches every row of [tableId], optionally filtered by exact-match
  /// query parameters (e.g. `{'student_id': 3}`).
  static Future<List<Map<String, dynamic>>> getList(
    String tableId, {
    Map<String, dynamic>? filters,
  }) async {
    final res = await http.get(_uri('api', tableId, filters), headers: _headers);

    if (res.statusCode == 404) return [];
    if (res.statusCode != 200) {
      throw ApiException('Ma\'lumotlarni olishda xatolik', statusCode: res.statusCode);
    }

    final decoded = _decode(res);
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    if (decoded is Map && decoded['value'] is List) {
      return (decoded['value'] as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return [];
  }

  /// Fetches a single row by [id], or null if it doesn't exist.
  static Future<Map<String, dynamic>?> getOne(String tableId, int id) async {
    final rows = await getList(tableId, filters: {'id': id});
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// Creates a new row and returns its assigned id, if the backend reports
  /// one back; otherwise returns null (caller should re-fetch if it needs
  /// the id immediately).
  static Future<int?> create(String tableId, Map<String, dynamic> body) async {
    final data = await _postForm(_uri('api-in', tableId), _toFields(body));
    final id = data['lastInsertId'] ?? data['id'];
    return id == null ? null : int.tryParse(id.toString());
  }

  /// Updates the row identified by [id] with the given [body] (only the
  /// changed fields need to be included).
  static Future<void> update(String tableId, int id, Map<String, dynamic> body) async {
    final fields = _toFields(body);
    fields['where'] = 'id:$id';
    final data = await _postForm(_uri('api-up', tableId), fields);
    if (!_isSuccess(data)) {
      throw ApiException('Yozuvni yangilashda xatolik');
    }
  }

  /// Deletes the row identified by [id].
  static Future<void> delete(String tableId, int id) async {
    final res = await http.get(_uri('api-del', tableId, {'id': id}), headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Yozuvni o\'chirishda xatolik', statusCode: res.statusCode);
    }
    final decoded = _decode(res);
    if (!_isSuccess(decoded)) {
      throw ApiException('Yozuvni o\'chirishda xatolik');
    }
  }
}
