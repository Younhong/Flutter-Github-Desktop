import Cocoa
import FlutterMacOS

public class FlutterGithubPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_github_plugin", binaryMessenger: registrar.messenger)
    let instance = FlutterGithubPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "activate":
      NSApplication.shared.activate(ignoringOtherApps: true)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
