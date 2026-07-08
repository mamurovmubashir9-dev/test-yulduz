/// The VIPS backend returns every column as a string (typical of generic
/// MySQL-to-JSON generators), so numeric/boolean fields need lenient parsing
/// instead of a direct cast.
class ParseUtils {
  ParseUtils._();

  static int toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static int? toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static bool toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final str = value.toString().trim().toLowerCase();
    return str == '1' || str == 'true' || str == 'yes';
  }

  static String toStr(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static String? toStrOrNull(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }
}
