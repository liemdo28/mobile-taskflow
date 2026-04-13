/// App configuration
/// Chỉ thay đổi các giá trị ở đây khi deploy
class Env {
  /// API base URL - thay đổi khi deploy production
  /// Local dev: http://10.0.2.2:8888/ (Android emulator) / http://localhost:8888/ (iOS)
  /// Staging/Production: https://dashboard.bakudanramen.com/
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dashboard.bakudanramen.com',
  );

  static String get apiV1 => '$apiBaseUrl/api/v1';

  /// Timeout settings (milliseconds)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout    = 30000;

  /// Sync settings
  static const int syncPollIntervalSeconds = 10;
  static const int tokenRefreshThreshold  = 300; // Refresh if < 5 min left

  /// Cache settings
  static const int maxCacheAge = 7; // days
  static const int maxCacheSize = 50; // MB
}

/// Build mode
enum BuildMode { development, staging, production }

class AppConfig {
  static BuildMode buildMode = BuildMode.development;

  static void init() {
    // Detect from compile-time flag
    const env = String.fromEnvironment('BUILD_ENV', defaultValue: 'dev');
    if (env == 'prod') {
      buildMode = BuildMode.production;
    } else if (env == 'staging') {
      buildMode = BuildMode.staging;
    } else {
      buildMode = BuildMode.development;
    }
  }
}
