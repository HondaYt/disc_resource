import Flutter
import MusicKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  var eventSink: FlutterEventSink?
  // メソッドチャネルの定義
  private let methodChannelName = "com.hondayt.disc.resource"
  public var result: FlutterResult?
  public var currentAuthStatus: MusicAuthorization.Status?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    // let methodChannel = FlutterMethodChannel(
    //   name: methodChannelName, binaryMessenger: controller.binaryMessenger)

    // methodChannel.setMethodCallHandler { [weak self] methodCall, result in
    //   switch methodCall.method {
    //   case "requestAuth":
    //     Task {
    //       await MusicAuthorization.request()
    //     }
    //   case "checkAuthStatus":
    //     self?.checkAuthStatus(result: result)
    //   default:
    //     result(
    //       FlutterError(
    //         code: "UNAVAILABLE", message: "Method not available: \(methodCall.method)", details: nil
    //       ))
    //   }
    // }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  // private func checkAuthStatus(result: @escaping FlutterResult) {
  //   let status = MusicAuthorization.currentStatus
  //   let statusString: String
  //   switch status {
  //   case .authorized:
  //     statusString = "authorized"
  //   case .denied:
  //     statusString = "denied"
  //   case .notDetermined:
  //     statusString = "notDetermined"
  //   case .restricted:
  //     statusString = "restricted"
  //   @unknown default:
  //     statusString = "unknown"
  //   }
  //   result(statusString)
  // }
}
