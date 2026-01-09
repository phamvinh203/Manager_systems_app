import 'package:intl/intl.dart';

class Formatters {
  // === Date Formatters ===

  /// Format ngày dạng dd/MM/yyyy (VD: 15/01/2026)
  static String formatDateVN(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format ngày giờ dạng HH:mm dd/MM/yyyy (VD: 14:30 15/01/2026)
  static String formatDateTimeVN(DateTime date) {
    return DateFormat('HH:mm dd/MM/yyyy').format(date);
  }

  /// Format ngày dạng yyyy-MM-dd cho API (VD: 2026-01-15)
  static String formatDateApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format ngày dạng tiếng Anh (VD: Jan 15, 2026)
  static String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // === Currency Formatters ===

  static String formatVND(num amount) {
    final intAmount = amount.toInt();
    final formatted = intAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  // === Number Formatters ===

  /// Format số ngày: nếu là số nguyên thì bỏ .0, nếu có số lẻ thì giữ lại
  /// Ví dụ: 3.0 -> "3", 3.5 -> "3.5"
  static String formatDays(double days) {
    if (days == days.truncateToDouble()) {
      return days.toInt().toString();
    }
    return days.toString();
  }
}
