import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// TaskFlow color palette
/// Dark-first theme, giữ consistent với web PWA
class AppColors {
  // Brand
  static const Color primary       = Color(0xFFDC2626);
  static const Color primaryDark   = Color(0xFF991B1B);
  static const Color primaryLight  = Color(0xFFFCA5A5);

  // Dark theme (default)
  static const Color bgPrimary     = Color(0xFF09090B);
  static const Color bgSecondary   = Color(0xFF18181B);
  static const Color bgTertiary    = Color(0xFF27272A);
  static const Color bgCard        = Color(0xFF1C1C1E);
  static const Color bgElevated    = Color(0xFF2C2C2E);

  // Light theme
  static const Color bgLightPrimary   = Color(0xFFFFFFFF);
  static const Color bgLightSecondary = Color(0xFFF4F4F5);
  static const Color bgLightTertiary  = Color(0xFFE4E4E7);
  static const Color bgLightCard       = Color(0xFFFFFFFF);
  static const Color bgLightElevated   = Color(0xFFF9FAFB);

  // Text
  static const Color textPrimary   = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary  = Color(0xFF71717A);
  static const Color textDisabled  = Color(0xFF52525B);
  static const Color textLightPrimary   = Color(0xFF18181B);
  static const Color textLightSecondary = Color(0xFF71717A);

  // Priority colors
  static const Color priorityUrgent = Color(0xFFDC2626);
  static const Color priorityHigh    = Color(0xFFF59E0B);
  static const Color priorityMedium  = Color(0xFF3B82F6);
  static const Color priorityLow     = Color(0xFF71717A);

  // Status colors
  static const Color statusTodo       = Color(0xFF71717A);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusReview     = Color(0xFFF59E0B);
  static const Color statusDone       = Color(0xFF22C55E);

  // Utility
  static const Color success    = Color(0xFF22C55E);
  static const Color warning    = Color(0xFFF59E0B);
  static const Color error      = Color(0xFFEF4444);
  static const Color info       = Color(0xFF3B82F6);
  static const Color divider    = Color(0xFF27272A);
  static const Color border     = Color(0xFF3F3F46);
  static const Color shimmer    = Color(0xFF27272A);
}

/// String constants
class AppStrings {
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';

  // Navigation
  static const String navHome     = 'Home';
  static const String navMyTasks  = 'My Tasks';
  static const String navCalendar = 'Calendar';
  static const String navInbox    = 'Inbox';
  static const String navProfile  = 'Profile';

  // Task statuses
  static const Map<String, String> taskStatuses = {
    'todo': 'To Do',
    'in_progress': 'In Progress',
    'review': 'Review',
    'done': 'Done',
  };

  // Task priorities
  static const Map<String, String> taskPriorities = {
    'urgent': 'Urgent',
    'high': 'High',
    'medium': 'Medium',
    'low': 'Low',
  };

  // Date formats
  static const String dateFormat  = 'dd/MM/yyyy';
  static const String timeFormat  = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}

/// Priority utilities
class PriorityUtils {
  static String label(String priority) {
    return switch (priority) {
      'urgent' => 'Khẩn cấp',
      'high' => 'Cao',
      'medium' => 'Trung bình',
      'low' => 'Thấp',
      _ => priority,
    };
  }

  static Color color(String priority) {
    return switch (priority) {
      'urgent' => AppColors.priorityUrgent,
      'high' => AppColors.priorityHigh,
      'medium' => AppColors.priorityMedium,
      'low' => AppColors.priorityLow,
      _ => AppColors.priorityLow,
    };
  }

  static const List<String> all = ['urgent', 'high', 'medium', 'low'];
}

/// Status utilities
class StatusUtils {
  static String label(String status) {
    return switch (status) {
      'todo' => 'To Do',
      'in_progress' => 'Đang làm',
      'review' => 'Review',
      'done' => 'Hoàn thành',
      _ => status,
    };
  }

  static Color color(String status) {
    return switch (status) {
      'todo' => AppColors.statusTodo,
      'in_progress' => AppColors.statusInProgress,
      'review' => AppColors.statusReview,
      'done' => AppColors.statusDone,
      _ => AppColors.textTertiary,
    };
  }

  static const List<String> all = ['todo', 'in_progress', 'review', 'done'];
}

/// API endpoints - single source of truth
class ApiEndpoints {
  static const String base = '/api/v1';

  // Auth
  static const String login           = '$base/auth/login';
  static const String register       = '$base/auth/register';
  static const String logout          = '$base/auth/logout';
  static const String refresh        = '$base/auth/refresh';
  static const String me             = '$base/auth/me';
  static const String forgotPassword  = '$base/auth/forgot-password';
  static const String resetPassword  = '$base/auth/reset-password';
  static const String logoutAll       = '$base/auth/logout-all';

  // Tasks
  static const String tasks          = '$base/tasks';
  static String task(int id)         => '$base/tasks/$id';
  static String taskStatus(int id)    => '$base/tasks/$id/status';
  static String taskAssign(int id)    => '$base/tasks/$id/assign';
  static String taskComments(int id)  => '$base/tasks/$id/comments';

  // My Tasks
  static const String myTasks         = '$base/me/tasks';
  static const String myTasksNew       = '$base/me/tasks/new';
  static String acceptTask(int id)    => '$base/me/tasks/$id/accept';

  // Notifications
  static const String notifications    = '$base/notifications';
  static const String notifUnreadCount = '$base/notifications/unread-count';
  static const String notifReadAll     = '$base/notifications/read-all';

  // Dashboard
  static const String dashboardSummary = '$base/dashboard/summary';

  // Calendar
  static const String calendar = '$base/calendar';

  // Projects
  static const String projects  = '$base/projects';
  static String project(int id) => '$base/projects/$id';

  // Users
  static const String users        = '$base/users';
  static const String userProfile  = '$base/users/profile';
  static const String userPassword = '$base/users/password';
  static const String pushToken    = '$base/users/push-token';

  // Upload
  static const String upload = '$base/upload';

  // Sync
  static const String syncPoll  = '$base/sync/poll';
  static const String syncStatus = '$base/sync/status';
}
