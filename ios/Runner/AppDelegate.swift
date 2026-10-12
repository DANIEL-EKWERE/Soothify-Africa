import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Without the delegate, a notification that arrives while the app is in
    // the foreground is swallowed by iOS, and a tap never reaches Flutter.
    UNUserNotificationCenter.current().delegate = self
    // Registers for an APNs token. Firebase cannot mint an FCM token on iOS
    // until APNs has issued one.
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
