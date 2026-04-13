import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../storage/secure_storage.dart';

/// Dio HTTP client cho TaskFlow API
class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: Env.connectTimeout),
        receiveTimeout: const Duration(milliseconds: Env.receiveTimeout),
        sendTimeout: const Duration(milliseconds: Env.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Platform': 'mobile',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      if (kDebugMode) _LoggingInterceptor(),
      _RetryInterceptor(_dio),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath,
    String fieldName, {
    Map<String, dynamic>? fields,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      ...?fields,
      fieldName: await MultipartFile.fromFile(filePath),
    });
    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}

// ── Auth Interceptor ─────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_QueuedRequest> _pending = [];

  _AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path.contains('/auth/login') || options.path.contains('/auth/register')) {
      return handler.next(options);
    }
    _storage.getAccessToken().then((token) {
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      _storage.getDeviceId().then((deviceId) {
        if (deviceId != null) {
          options.headers['X-Device-Id'] = deviceId;
        }
        handler.next(options);
      });
    });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    if (_isRefreshing) {
      final completer = Completer<Response<dynamic>>();
      _pending.add(_QueuedRequest(err.requestOptions, completer));
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (_) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        await _storage.clearAll();
        return handler.next(err);
      }

      final refreshDio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
      final resp = await refreshDio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (resp.statusCode == 200 && resp.data['data'] != null) {
        final tokens = resp.data['data']['tokens'] as Map<String, dynamic>;
        await _storage.saveTokens(
          tokens['access_token'] as String,
          tokens['refresh_token'] as String,
        );
        err.requestOptions.headers['Authorization'] = 'Bearer ${tokens['access_token']}';
        final retryResp = await _dio.fetch(err.requestOptions);
        return handler.resolve(retryResp);
      }

      await _storage.clearAll();
      return handler.next(err);
    } catch (_) {
      await _storage.clearAll();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
      for (final req in _pending) {
        req.completer.completeError(err);
      }
      _pending.clear();
    }
  }
}

class _QueuedRequest {
  final RequestOptions requestOptions;
  final Completer<Response<dynamic>> completer;
  _QueuedRequest(this.requestOptions, this.completer);
}

// ── Retry Interceptor ────────────────────────────────────────────

class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int maxRetries = 2;

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = (err.requestOptions.extra['retryCount'] ?? 0) as int;
    if (retryCount >= maxRetries) return handler.next(err);

    if (_isRetryable(err)) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      await Future.delayed(Duration(seconds: retryCount + 1));
      try {
        final resp = await _dio.fetch(err.requestOptions);
        return handler.resolve(resp);
      } catch (e) {
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  bool _isRetryable(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.receiveTimeout ||
      (err.response?.statusCode != null && err.response!.statusCode! >= 500);
}

// ── Logging Interceptor ──────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🌐 [API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ [API] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ [API] ${err.response?.statusCode} ${err.requestOptions.path} — ${err.message}');
    handler.next(err);
  }
}
