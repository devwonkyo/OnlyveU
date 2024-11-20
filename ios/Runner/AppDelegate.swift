import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseRemoteConfig

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   // RemoteConfig에서 API 키 가져오기
      if let mapApiKey = RemoteConfig.remoteConfig().configValue(forKey: "map_api").stringValue {
        GMSServices.provideAPIKey(mapApiKey)
      }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
