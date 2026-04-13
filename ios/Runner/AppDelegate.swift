import UIKit
import Flutter
import Firebase

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Firebase setup
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      Messaging.messaging().delegate = self as MessagingDelegate
    }

    // Register for remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
          DispatchQueue.main.async {
            application.registerForRemoteNotifications()
          }
        }
      }
    }

    // Flutter setup
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── Push notification delegate ────────────────────────────────

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("📱 Push token: \(token)")

    // Send token to Flutter via FlutterMethodChannel
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.taskflow.mobile/push_token",
        binaryMessenger: controller.binaryMessenger
      )
      channel.invokeMethod("onTokenRefresh", arguments: token)
    }

    Messaging.messaging().apnsToken = deviceToken
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Failed to register for remote notifications: \(error)")
  }

  // ── Firebase Cloud Messaging ────────────────────────────────

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    completionHandler(UIBackgroundFetchResult.newData)
  }

  // ── Deep link handling ──────────────────────────────────────

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }
}

// ── MessagingDelegate ──────────────────────────────────────────

@available(iOS 10.0, *)
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let token = fcmToken else { return }
    print("🔥 FCM token: \(token)")

    // Broadcast to Flutter
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.taskflow.mobile/push_token",
        binaryMessenger: controller.binaryMessenger
      )
      channel.invokeMethod("onTokenRefresh", arguments: token)
    }
  }

  func messaging(
    _ messaging: Messaging,
    didReceive remoteMessage: MessagingRemoteMessage
  ) {
    print("📩 Received remote message: \(remoteMessage.appData)")
  }
}
