import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../models/models.dart';

/// TaskFlow API Service
/// Tất cả gọi API từ đây
class ApiService {
  final ApiClient _client;
  final SecureStorageService _storage;

  ApiService(this._client, this._storage);

  // ── Auth ──────────────────────────────────────────────────────

  Future<AuthResult> login({
    required String email,
    required String password,
    required String platform,
    String? deviceId,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    final resp = await _client.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
        'platform': platform,
        'device_id': deviceId,
        'device_name': deviceName,
        'app_version': appVersion,
        'os_version': osVersion,
      },
    );

    final data = resp.data as Map<String, dynamic>;
    final tokens = data['data']['tokens'] as Map<String, dynamic>;
    final user = User.fromJson(data['data']['user'] as Map<String, dynamic>);

    await _storage.saveTokens(
      tokens['access_token'] as String,
      tokens['refresh_token'] as String,
    );
    await _storage.saveUserSession(user.id, user.email);

    return AuthResult(user: user, tokens: tokens);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String platform,
    String? deviceId,
    String? deviceName,
  }) async {
    final resp = await _client.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'platform': platform,
        'device_id': deviceId,
        'device_name': deviceName,
      },
    );

    final data = resp.data as Map<String, dynamic>;
    final tokens = data['data']['tokens'] as Map<String, dynamic>;
    final user = User.fromJson(data['data']['user'] as Map<String, dynamic>);

    await _storage.saveTokens(
      tokens['access_token'] as String,
      tokens['refresh_token'] as String,
    );
    await _storage.saveUserSession(user.id, user.email);

    return AuthResult(user: user, tokens: tokens);
  }

  Future<void> logout({String? deviceId}) async {
    try {
      await _client.post(ApiEndpoints.logout, data: {'device_id': deviceId});
    } catch (_) {}
    await _storage.clearAll();
  }

  Future<User> getMe() async {
    final resp = await _client.get(ApiEndpoints.me);
    final data = resp.data as Map<String, dynamic>;
    return User.fromJson(data['data']['user'] as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) async {
    await _client.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  // ── Dashboard ──────────────────────────────────────────────────

  Future<DashboardResult> getDashboard() async {
    final resp = await _client.get(ApiEndpoints.dashboardSummary);
    final data = resp.data as Map<String, dynamic>;
    final stats = DashboardStats.fromJson(data['data']['stats'] as Map<String, dynamic>);
    final recentTasks = (data['data']['recent_tasks'] as List<dynamic>)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
    final upcomingTasks = (data['data']['upcoming_tasks'] as List<dynamic>)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
    return DashboardResult(stats: stats, recentTasks: recentTasks, upcomingTasks: upcomingTasks);
  }

  // ── Tasks ──────────────────────────────────────────────────────

  Future<TaskListResult> getTasks({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    String? priority,
    int? assigneeId,
    int? projectId,
    String? view,
    bool overdue = false,
    String sortBy = 'created_at',
    String sortDir = 'DESC',
  }) async {
    final resp = await _client.get(
      ApiEndpoints.tasks,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (priority != null && priority.isNotEmpty) 'priority': priority,
        if (assigneeId != null) 'assignee_id': assigneeId,
        if (projectId != null) 'project_id': projectId,
        if (view != null && view.isNotEmpty) 'view': view,
        if (overdue) 'overdue': '1',
        'sort_by': sortBy,
        'sort_dir': sortDir,
      },
    );

    final data = resp.data as Map<String, dynamic>;
    final meta = data['meta'] as Map<String, dynamic>;
    final pagination = meta['pagination'] as Map<String, dynamic>;
    final items = (data['data']['items'] as List<dynamic>)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();

    return TaskListResult(
      tasks: items,
      page: pagination['page'] as int,
      perPage: pagination['per_page'] as int,
      total: pagination['total'] as int,
      hasMore: pagination['has_more'] as bool,
    );
  }

  Future<Task> getTask(int id) async {
    final resp = await _client.get(ApiEndpoints.task(id));
    final data = resp.data as Map<String, dynamic>;
    return Task.fromJson(data['data']['task'] as Map<String, dynamic>);
  }

  Future<Task> createTask({
    required int projectId,
    required String title,
    String? description,
    int? sectionId,
    int? assigneeId,
    String? priority,
    String? status,
    DateTime? dueDate,
    DateTime? startDate,
  }) async {
    final resp = await _client.post(
      ApiEndpoints.tasks,
      data: {
        'project_id': projectId,
        'title': title,
        if (description != null) 'description': description,
        if (sectionId != null) 'section_id': sectionId,
        if (assigneeId != null) 'assignee_id': assigneeId,
        if (priority != null) 'priority': priority,
        if (status != null) 'status': status,
        if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T')[0],
        if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
      },
    );

    final data = resp.data as Map<String, dynamic>;
    return Task.fromJson(data['data']['task'] as Map<String, dynamic>);
  }

  Future<Task> updateTask(int id, Map<String, dynamic> data) async {
    final resp = await _client.put(ApiEndpoints.task(id), data: data);
    final result = resp.data as Map<String, dynamic>;
    return Task.fromJson(result['data']['task'] as Map<String, dynamic>);
  }

  Future<Task> changeTaskStatus(int id, String status) async {
    final resp = await _client.patch(ApiEndpoints.taskStatus(id), data: {'status': status});
    final data = resp.data as Map<String, dynamic>;
    return Task.fromJson(data['data']['task'] as Map<String, dynamic>);
  }

  Future<Task> assignTask(int id, int? assigneeId) async {
    final resp = await _client.patch(ApiEndpoints.taskAssign(id), data: {'assignee_id': assigneeId});
    final data = resp.data as Map<String, dynamic>;
    return Task.fromJson(data['data']['task'] as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) async {
    await _client.delete('${ApiEndpoints.tasks}/$id/delete');
  }

  // ── My Tasks ──────────────────────────────────────────────────

  Future<MyTasksResult> getMyTasks({
    String group = 'all',
    int page = 1,
    int perPage = 50,
  }) async {
    final resp = await _client.get(
      ApiEndpoints.myTasks,
      queryParameters: {
        'group': group,
        'page': page,
        'per_page': perPage,
      },
    );

    final data = resp.data as Map<String, dynamic>;
    final tasks = (data['data']['tasks'] as List<dynamic>)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
    final counts = data['data']['counts'] as Map<String, dynamic>;

    return MyTasksResult(
      tasks: tasks,
      counts: TaskCounts(
        active: counts['active'] as int? ?? 0,
        today: counts['today'] as int? ?? 0,
        upcoming: counts['upcoming'] as int? ?? 0,
        overdue: counts['overdue'] as int? ?? 0,
        completed: counts['completed'] as int? ?? 0,
      ),
    );
  }

  Future<List<Task>> getNewTasks() async {
    final resp = await _client.get(ApiEndpoints.myTasksNew);
    final data = resp.data as Map<String, dynamic>;
    return (data['data']['tasks'] as List<dynamic>)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptTask(int taskId, {DateTime? dueDate}) async {
    await _client.post(
      ApiEndpoints.acceptTask(taskId),
      data: dueDate != null ? {'due_date': dueDate.toIso8601String().split('T')[0]} : null,
    );
  }

  // ── Comments ──────────────────────────────────────────────────

  Future<List<Comment>> getComments(int taskId) async {
    final resp = await _client.get(ApiEndpoints.taskComments(taskId));
    final data = resp.data as Map<String, dynamic>;
    return (data['data']['comments'] as List<dynamic>)
        .map((c) => Comment.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<Comment> addComment(int taskId, String content) async {
    final resp = await _client.post(ApiEndpoints.taskComments(taskId), data: {'content': content});
    final data = resp.data as Map<String, dynamic>;
    return Comment.fromJson(data['data']['comment'] as Map<String, dynamic>);
  }

  // ── Notifications ─────────────────────────────────────────────

  Future<NotificationResult> getNotifications({
    int page = 1,
    String? type,
    bool unreadOnly = false,
  }) async {
    final resp = await _client.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'per_page': 30,
        if (type != null) 'type': type,
        if (unreadOnly) 'unread_only': '1',
      },
    );

    final data = resp.data as Map<String, dynamic>;
    final notifs = (data['data']['notifications'] as List<dynamic>)
        .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
        .toList();
    final unreadCount = data['data']['unread_count'] as int;

    return NotificationResult(notifications: notifs, unreadCount: unreadCount);
  }

  Future<int> getUnreadCount() async {
    final resp = await _client.get(ApiEndpoints.notifUnreadCount);
    final data = resp.data as Map<String, dynamic>;
    return data['data']['unread_count'] as int? ?? 0;
  }

  Future<void> markAllRead() async {
    await _client.patch(ApiEndpoints.notifReadAll);
  }

  // ── Calendar ───────────────────────────────────────────────────

  Future<List<CalendarDay>> getCalendar(int year, int month) async {
    final resp = await _client.get(
      ApiEndpoints.calendar,
      queryParameters: {'year': year, 'month': month},
    );
    final data = resp.data as Map<String, dynamic>;
    return (data['data']['days'] as List<dynamic>)
        .map((d) => CalendarDay.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  // ── Projects ──────────────────────────────────────────────────

  Future<List<Project>> getProjects() async {
    final resp = await _client.get(ApiEndpoints.projects);
    final data = resp.data as Map<String, dynamic>;
    return (data['data']['projects'] as List<dynamic>)
        .map((p) => Project.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  // ── Users ────────────────────────────────────────────────────

  Future<List<User>> getUsers() async {
    final resp = await _client.get(ApiEndpoints.users);
    final data = resp.data as Map<String, dynamic>;
    return (data['data']['users'] as List<dynamic>)
        .map((u) => User.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final resp = await _client.put(ApiEndpoints.userProfile, data: data);
    final result = resp.data as Map<String, dynamic>;
    return User.fromJson(result['data']['user'] as Map<String, dynamic>);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.put(
      ApiEndpoints.userPassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': newPassword,
      },
    );
  }

  // ── Upload ────────────────────────────────────────────────────

  Future<AttachmentResult> uploadFile(
    String filePath, {
    int? taskId,
    void Function(int, int)? onProgress,
  }) async {
    final resp = await _client.uploadFile(
      ApiEndpoints.upload,
      filePath,
      'file',
      fields: taskId != null ? {'task_id': taskId.toString()} : null,
      onSendProgress: onProgress,
    );

    final data = resp.data as Map<String, dynamic>;
    return AttachmentResult(
      id: data['data']['id'] as int?,
      filename: data['data']['filename'] as String,
      originalName: data['data']['original_name'] as String,
      url: data['data']['url'] as String,
      fileSize: data['data']['file_size'] as int,
    );
  }

  // ── Push Token ────────────────────────────────────────────────

  Future<void> registerPushToken(String pushToken, String platform, String deviceId) async {
    await _client.put(ApiEndpoints.pushToken, data: {
      'push_token': pushToken,
      'platform': platform,
      'device_id': deviceId,
    });
  }
}

// ── Result types ─────────────────────────────────────────────────

class AuthResult {
  final User user;
  final Map<String, dynamic> tokens;
  AuthResult({required this.user, required this.tokens});
}

class DashboardResult {
  final DashboardStats stats;
  final List<Task> recentTasks;
  final List<Task> upcomingTasks;
  DashboardResult({required this.stats, required this.recentTasks, required this.upcomingTasks});
}

class TaskListResult {
  final List<Task> tasks;
  final int page, perPage, total;
  final bool hasMore;
  TaskListResult({required this.tasks, required this.page, required this.perPage, required this.total, required this.hasMore});
}

class MyTasksResult {
  final List<Task> tasks;
  final TaskCounts counts;
  MyTasksResult({required this.tasks, required this.counts});
}

class TaskCounts {
  final int active, today, upcoming, overdue, completed;
  TaskCounts({required this.active, required this.today, required this.upcoming, required this.overdue, required this.completed});
}

class NotificationResult {
  final List<AppNotification> notifications;
  final int unreadCount;
  NotificationResult({required this.notifications, required this.unreadCount});
}

class AttachmentResult {
  final int? id;
  final String filename;
  final String originalName;
  final String url;
  final int fileSize;
  AttachmentResult({this.id, required this.filename, required this.originalName, required this.url, required this.fileSize});
}
