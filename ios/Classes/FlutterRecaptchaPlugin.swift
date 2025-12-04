import Flutter
import UIKit
import LocalAuthentication
import CryptoKit
import CommonCrypto

public class FlutterRecaptchaPlugin: NSObject, FlutterPlugin {
  private var config: [String: Any]?
  private var behavioralStartTime: TimeInterval = 0
  private var behavioralData: [[String: Any]] = []

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_recaptcha", binaryMessenger: registrar.messenger())
    let instance = FlutterRecaptchaPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initialize":
      initialize(arguments: call.arguments as? [String: Any], result: result)
    case "verify":
      verify(arguments: call.arguments as? [String: Any], result: result)
    case "isBiometricAvailable":
      result(isBiometricAvailable())
    case "authenticateWithBiometric":
      authenticateWithBiometric(result: result)
    case "startBehavioralAnalysis":
      startBehavioralAnalysis(result: result)
    case "stopBehavioralAnalysis":
      stopBehavioralAnalysis(result: result)
    case "getDeviceFingerprint":
      result(getDeviceFingerprint())
    case "reset":
      reset(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initialize(arguments: [String: Any]?, result: @escaping FlutterResult) {
    config = arguments
    result(true)
  }

  private func verify(arguments: [String: Any]?, result: @escaping FlutterResult) {
    let action = arguments?["action"] as? String

    // Simulate verification process
    let score = Double.random(in: 0.7...1.0)
    let success = score > 0.8

    let resultMap: [String: Any] = [
      "success": success,
      "token": success ? "ios_token_\(Int(Date().timeIntervalSince1970 * 1000))" : NSNull(),
      "score": score,
      "challengeType": "traditional",
      "metadata": [
        "platform": "ios",
        "action": action ?? NSNull(),
        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
      ]
    ]

    result(resultMap)
  }

  private func isBiometricAvailable() -> Bool {
    let context = LAContext()
    var error: NSError?

    return context.canEvaluatePolicy(.biometryAny, error: &error)
  }

  private func authenticateWithBiometric(result: @escaping FlutterResult) {
    guard isBiometricAvailable() else {
      result([
        "success": false,
        "errorMessage": "Biometric authentication not available"
      ])
      return
    }

    let context = LAContext()
    let reason = "Use biometric authentication to verify reCAPTCHA"

    context.evaluatePolicy(.biometryAny, localizedReason: reason) { success, error in
      DispatchQueue.main.async {
        if success {
          result([
            "success": true,
            "token": "biometric_token_\(Int(Date().timeIntervalSince1970 * 1000))",
            "score": 1.0,
            "challengeType": "biometric",
            "metadata": [
              "platform": "ios",
              "biometricType": self.getBiometricType(),
              "timestamp": Int(Date().timeIntervalSince1970 * 1000)
            ]
          ])
        } else {
          result([
            "success": false,
            "errorMessage": error?.localizedDescription ?? "Authentication failed"
          ])
        }
      }
    }
  }

  private func getBiometricType() -> String {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.biometryAny, error: &error) else {
      return "none"
    }

    switch context.biometryType {
    case .faceID:
      return "faceID"
    case .touchID:
      return "touchID"
    case .opticID:
      return "opticID"
    default:
      return "unknown"
    }
  }

  private func startBehavioralAnalysis(result: @escaping FlutterResult) {
    behavioralStartTime = Date().timeIntervalSince1970
    behavioralData.removeAll()
    result(nil)
  }

  private func stopBehavioralAnalysis(result: @escaping FlutterResult) {
    let duration = Date().timeIntervalSince1970 - behavioralStartTime
    let score = calculateBehavioralScore(duration: duration)

    let resultMap: [String: Any] = [
      "success": score > 0.6,
      "token": score > 0.6 ? "behavioral_token_\(Int(Date().timeIntervalSince1970 * 1000))" : NSNull(),
      "score": score,
      "challengeType": "behavioral",
      "metadata": [
        "platform": "ios",
        "duration": duration * 1000, // Convert to milliseconds
        "dataPoints": behavioralData.count,
        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
      ]
    ]

    result(resultMap)
  }

  private func calculateBehavioralScore(duration: TimeInterval) -> Double {
    var score = 0.5

    if duration > 1.0 { score += 0.2 } // More than 1 second
    if duration < 10.0 { score += 0.2 } // Less than 10 seconds
    if behavioralData.count > 5 { score += 0.1 } // Some interaction data

    return min(max(score, 0.0), 1.0)
  }

  private func getDeviceFingerprint() -> String {
    var deviceInfo = ""

    deviceInfo += UIDevice.current.model
    deviceInfo += UIDevice.current.systemName
    deviceInfo += UIDevice.current.systemVersion
    deviceInfo += UIDevice.current.identifierForVendor?.uuidString ?? ""

    return sha256(deviceInfo)
  }

  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
  }

  private func reset(result: @escaping FlutterResult) {
    config = nil
    behavioralData.removeAll()
    behavioralStartTime = 0
    result(nil)
  }
}

