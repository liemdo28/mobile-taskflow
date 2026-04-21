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
