import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../core/theme/app_theme.dart';
import '../shared/services/api_services.dart';
import '../shared/models/models.dart';

// ── Core services ──────────────────────────────────────────────

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final localCacheProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return ApiService(client, storage);
});

// ── Theme ──────────────────────────────────────────────────────

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// ── Auth state ─────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  final SecureStorageService _storage;
  final LocalCacheService _cache;

  AuthNotifier(this._api, this._storage, this._cache) : super(const AuthState());

  Future<void> checkSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    final hasSession = await _storage.hasValidSession();
    if (hasSession) {
      try {
        final user = await _api.getMe();
        await _cache.cacheProfile({'id': user.id, 'name': user.name, 'email': user.email, 'avatar': user.avatar, 'role': user.role});
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (e) {
        await _storage.clearAll();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _api.login(
        email: email,
        password: password,
        platform: ThemeMode.dark == Brightness.dark ? 'android' : 'ios',
        deviceId: await _storage.getDeviceId(),
      );
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _extractError(e),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _api.register(
        name: name, email: email, password: password,
        platform: 'android',
        deviceId: await _storage.getDeviceId(),
      );
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _extractError(e),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout(deviceId: await _storage.getDeviceId());
    } catch (_) {}
    await _storage.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }

  String _extractError(Object e) {
    // Handle DioException
    try {
      final resp = (e as dynamic).response;
      if (resp?.data != null) {
        return resp.data['message'] as String? ?? 'Login failed';
      }
    } catch (_) {}
    return 'Login failed. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(secureStorageProvider),
    ref.watch(localCacheProvider),
  );
});

// ── Dashboard ──────────────────────────────────────────────────

final dashboardProvider = FutureProvider.autoDispose<DashboardResult>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getDashboard();
});

// ── My Tasks ──────────────────────────────────────────────────

final myTasksGroupProvider = StateProvider<String>((ref) => 'all');

final myTasksProvider = FutureProvider.autoDispose<MyTasksResult>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final group = ref.watch(myTasksGroupProvider);
  return api.getMyTasks(group: group);
});

// ── Task List ─────────────────────────────────────────────────

final taskListParamsProvider = StateProvider<TaskListParams>((ref) => TaskListParams());

class TaskListParams {
  final int page;
  final String? search;
  final String? status;
  final String? priority;
  final int? projectId;
  final String sortBy;
  final String sortDir;

  TaskListParams({
    this.page = 1,
    this.search,
    this.status,
    this.priority,
    this.projectId,
    this.sortBy = 'due_date',
    this.sortDir = 'ASC',
  });

  TaskListParams copyWith({
    int? page, String? search, String? status,
    String? priority, int? projectId, String? sortBy, String? sortDir,
  }) {
    return TaskListParams(
      page: page ?? this.page,
      search: search ?? this.search,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      sortBy: sortBy ?? this.sortBy,
      sortDir: sortDir ?? this.sortDir,
    );
  }
}

final taskListProvider = FutureProvider.autoDispose<TaskListResult>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final params = ref.watch(taskListParamsProvider);
  return api.getTasks(
    page: params.page,
    search: params.search,
    status: params.status,
    priority: params.priority,
    projectId: params.projectId,
    sortBy: params.sortBy,
    sortDir: params.sortDir,
  );
});

// ── Task Detail ───────────────────────────────────────────────

final taskDetailProvider = FutureProvider.family.autoDispose<Task, int>((ref, taskId) async {
  final api = ref.watch(apiServiceProvider);
  return api.getTask(taskId);
});

final taskCommentsProvider = FutureProvider.family.autoDispose<List<Comment>, int>((ref, taskId) async {
  final api = ref.watch(apiServiceProvider);
  return api.getComments(taskId);
});

// ── Calendar ──────────────────────────────────────────────────

final calendarMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final calendarProvider = FutureProvider.autoDispose<List<CalendarDay>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final month = ref.watch(calendarMonthProvider);
  return api.getCalendar(month.year, month.month);
});

// ── Notifications ─────────────────────────────────────────────

final notificationsProvider = FutureProvider.autoDispose<NotificationResult>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getNotifications();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getUnreadCount();
});

// ── Projects ──────────────────────────────────────────────────

final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getProjects();
});

// ── Users ────────────────────────────────────────────────────

final usersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getUsers();
});
