import 'package:intl/intl.dart';

/// Date utility helpers cho TaskFlow
class DateUtils {
  /// Format: "Hôm nay", "Ngày mai", "Hôm qua", "dd/MM"
  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Ngày mai';
    if (diff == -1) return 'Hôm qua';
    if (diff > 0 && diff < 7) return 'Thứ ${_weekday(date.weekday)}';
    if (diff < 0 && diff > -7) return '${diff.abs()} ngày trước';
    return DateFormat('dd/MM').format(date);
  }

  static String _weekday(int w) {
    return ['CN','T2','T3','T4','T5','T6','T7'][w];
  }

  /// Format: "2 giờ trước", "3 phút trước", "Vừa xong"
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) return DateFormat('dd/MM/yyyy').format(date);
    if (diff.inDays > 0) return '${diff.inDays}d trước';
    if (diff.inHours > 0) return '${diff.inHours}h trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes}p trước';
    return 'Vừa xong';
  }

  /// Due date color
  static String dueDateColor(DateTime? dueDate, bool isCompleted) {
    if (isCompleted || dueDate == null) return 'muted';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final days = due.difference(today).inDays;

    if (days < 0) return 'overdue';  // Đỏ
    if (days == 0) return 'today';    // Hồng
    if (days <= 3) return 'soon';     // Vàng
    return 'normal';                  // Xanh
  }

  /// Parse date string từ API
  static DateTime? parseApiDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Format cho input date picker
  static String formatForPicker(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Month range string: "Tháng 4, 2026"
  static String monthLabel(int year, int month) {
    final dt = DateTime(year, month);
    return 'Tháng $month, $year';
  }
}

/// Priority helpers
class PriorityUtils {
  static const List<String> all = ['urgent', 'high', 'medium', 'low'];

  static String label(String priority) {
    return {'urgent': 'Khẩn cấp', 'high': 'Cao', 'medium': 'Trung bình', 'low': 'Thấp'}[priority] ?? priority;
  }

  static int order(String priority) {
    return {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3}[priority] ?? 99;
  }
}

/// Status helpers
class StatusUtils {
  static const List<String> all = ['todo', 'in_progress', 'review', 'done'];

  static String label(String status) {
    return {
      'todo': 'To Do',
      'in_progress': 'In Progress',
      'review': 'Review',
      'done': 'Done',
    }[status] ?? status;
  }

  static double progress(String status) {
    return {
      'todo': 0.0,
      'in_progress': 0.33,
      'review': 0.66,
      'done': 1.0,
    }[status] ?? 0.0;
  }
}
