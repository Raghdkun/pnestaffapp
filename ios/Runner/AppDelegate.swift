import Flutter
import UIKit
import UserNotifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Background task identifiers — must match BGTaskSchedulerPermittedIdentifiers
    // in Info.plist and BackgroundTasks.*Unique in Dart.
    WorkmanagerPlugin.registerBGProcessingTask(
      withIdentifier: "com.pneunited.pnestaffapp.processing"
    )
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "com.pneunited.pnestaffapp.periodic_sync",
      frequency: NSNumber(value: 3600)
    )

    // Show local/FCM notifications while the app is in the foreground.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
