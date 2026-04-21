/// TaskFlow API response model
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? errors;
  final int timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    this.errors,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      meta: json['meta'] as Map<String, dynamic>?,
      errors: json['errors'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }
}

/// Task model
class Task {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final DateTime? startDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? acceptedAt;
  final int projectId;
  final int? sectionId;
  final int? assigneeId;
  final String? assigneeName;
  final String? assigneeAvatar;
  final int creatorId;
  final String? creatorName;
  final String? projectName;
  final String? projectColor;
  final String? sectionName;
  final String repeatType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.startDate,
    required this.isCompleted,
    this.completedAt,
    this.acceptedAt,
    required this.projectId,
    this.sectionId,
    this.assigneeId,
    this.assigneeName,
    this.assigneeAvatar,
    required this.creatorId,
    this.creatorName,
    this.projectName,
    this.projectColor,
    this.sectionName,
    this.repeatType = 'none',
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'todo',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'] as String) : null,
      isCompleted: (json['is_completed'] as int?) == 1 || json['is_completed'] == true,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      acceptedAt: json['accepted_at'] != null ? DateTime.tryParse(json['accepted_at'] as String) : null,
      projectId: (json['project_id'] as int?) ?? 0,
      sectionId: json['section_id'] as int?,
      assigneeId: json['assignee_id'] as int?,
      assigneeName: json['assignee_name'] as String?,
      assigneeAvatar: json['assignee_avatar'] as String?,
      creatorId: json['creator_id'] as int? ?? 0,
      creatorName: json['creator_name'] as String?,
      projectName: json['project_name'] as String?,
      projectColor: json['project_color'] as String?,
      sectionName: json['section_name'] as String?,
      repeatType: json['repeat_type'] as String? ?? 'none',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'status': status, 'priority': priority,
    'due_date': dueDate?.toIso8601String(),
    'start_date': startDate?.toIso8601String(),
    'is_completed': isCompleted ? 1 : 0,
    'project_id': projectId, 'section_id': sectionId,
    'assignee_id': assigneeId,
    'repeat_type': repeatType,
  };

  Task copyWith({
    int? id, String? title, String? description, String? status,
    String? priority, DateTime? dueDate, bool? isCompleted,
    int? sectionId, int? assigneeId, String? assigneeName,
    String? projectName, String? projectColor,
  }) {
    return Task(
      id: id ?? this.id, title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status, priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate, startDate: startDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt, acceptedAt: acceptedAt,
      projectId: projectId, sectionId: sectionId ?? this.sectionId,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatar: assigneeAvatar, creatorId: creatorId,
      creatorName: creatorName, projectName: projectName ?? this.projectName,
      projectColor: projectColor ?? this.projectColor,
      sectionName: sectionName, repeatType: repeatType,
      createdAt: createdAt, updatedAt: updatedAt,
    );
  }
}

/// User model
class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final String? preferredLanguage;
  final bool emailNotifications;
  final DateTime? createdAt;

  User({
    required this.id, required this.name, required this.email,
    this.avatar, this.role = 'member', this.preferredLanguage,
    this.emailNotifications = true, this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'member',
      preferredLanguage: json['preferred_language'] as String?,
      emailNotifications: (json['email_notifications'] as int?) == 1 || json['email_notifications'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

/// Notification model
class AppNotification {
  final int id;
  final String type;
  final String title;
  final String? message;
  final bool isRead;
  final String? deepLink;
  final int? taskId;
  final int? projectId;
  final int? fromUserId;
  final String? fromUserName;
  final String? fromUserAvatar;
  final DateTime createdAt;

  AppNotification({
    required this.id, required this.type, required this.title,
    this.message, required this.isRead, this.deepLink, this.taskId,
    this.projectId, this.fromUserId, this.fromUserName,
    this.fromUserAvatar, required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String?,
      isRead: (json['is_read'] as int?) == 1 || json['is_read'] == true,
      deepLink: json['deep_link'] as String?,
      taskId: json['task_id'] as int?,
      projectId: json['project_id'] as int?,
      fromUserId: json['from_user_id'] as int?,
      fromUserName: json['from_user_name'] as String?,
      fromUserAvatar: json['from_user_avatar'] as String?,
      createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
        : DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id, type: type, title: title, message: message,
      isRead: isRead ?? this.isRead, deepLink: deepLink,
      taskId: taskId, projectId: projectId,
      fromUserId: fromUserId, fromUserName: fromUserName,
      fromUserAvatar: fromUserAvatar, createdAt: createdAt,
    );
  }
}

/// Comment model
class Comment {
  final int id;
  final int taskId;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id, required this.taskId, required this.userId,
    this.userName, this.userAvatar, required this.content,
    required this.createdAt, this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      taskId: json['task_id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
        : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }
}

/// Project model
class Project {
  final int id;
  final String name;
  final String? description;
  final String color;
  final String status;
  final int ownerId;
  final String? ownerName;
  final int activeTasks;
  final int completedTasks;
  final DateTime? createdAt;

  Project({
    required this.id, required this.name, this.description,
    this.color = '#dc2626', this.status = 'active',
    required this.ownerId, this.ownerName,
    this.activeTasks = 0, this.completedTasks = 0, this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#dc2626',
      status: json['status'] as String? ?? 'active',
      ownerId: json['owner_id'] as int? ?? 0,
      ownerName: json['owner_name'] as String?,
      activeTasks: json['active_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

/// Dashboard stats
class DashboardStats {
  final int totalTasks;
  final int dueToday;
  final int overdue;
  final int assignedToMe;
  final int completedThisMonth;
  final int unreadNotifications;
  final int newTasks;

  DashboardStats({
    required this.totalTasks, required this.dueToday,
    required this.overdue, required this.assignedToMe,
    required this.completedThisMonth, required this.unreadNotifications,
    required this.newTasks,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalTasks: json['total_tasks'] as int? ?? 0,
      dueToday: json['due_today'] as int? ?? 0,
      overdue: json['overdue'] as int? ?? 0,
      assignedToMe: json['assigned_to_me'] as int? ?? 0,
      completedThisMonth: json['completed_this_month'] as int? ?? 0,
      unreadNotifications: json['unread_notifications'] as int? ?? 0,
      newTasks: json['new_tasks'] as int? ?? 0,
    );
  }
}

/// Calendar day
class CalendarDay {
  final String date;
  final int day;
  final int tasksCount;
  final List<Task> tasks;
  final bool isToday;
  final bool isOverdue;

  CalendarDay({
    required this.date, required this.day, required this.tasksCount,
    required this.tasks, this.isToday = false, this.isOverdue = false,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      date: json['date'] as String,
      day: json['day'] as int,
      tasksCount: json['tasks_count'] as int? ?? 0,
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
      isToday: json['is_today'] as bool? ?? false,
      isOverdue: json['is_overdue'] as bool? ?? false,
    );
  }
}
