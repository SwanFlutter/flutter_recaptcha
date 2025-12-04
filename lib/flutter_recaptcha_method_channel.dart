import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_recaptcha_platform_interface.dart';

/// An implementation of [FlutterRecaptchaPlatform] that uses method channels.
class MethodChannelFlutterRecaptcha extends FlutterRecaptchaPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_recaptcha');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> initialize(RecaptchaConfig config) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'initialize',
        config.toMap(),
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to initialize reCAPTCHA: ${e.message}');
      return false;
    }
  }

  @override
  Future<RecaptchaResult> verify({String? action}) async {
    try {
      final result = await methodChannel.invokeMethod('verify', {
        'action': action,
      });
      if (result != null && result is Map) {
        final resultMap = Map<String, dynamic>.from(result);
        return RecaptchaResult.fromMap(resultMap);
      }
      return const RecaptchaResult(
        success: false,
        errorMessage: 'No result received',
      );
    } on PlatformException catch (e) {
      return RecaptchaResult(
        success: false,
        errorMessage: e.message ?? 'Unknown error',
      );
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'isBiometricAvailable',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check biometric availability: ${e.message}');
      return false;
    }
  }

  @override
  Future<RecaptchaResult> authenticateWithBiometric() async {
    try {
      final result = await methodChannel.invokeMethod(
        'authenticateWithBiometric',
      );
      if (result != null && result is Map) {
        final resultMap = Map<String, dynamic>.from(result);
        return RecaptchaResult.fromMap(resultMap);
      }
      return const RecaptchaResult(
        success: false,
        errorMessage: 'Biometric authentication failed',
      );
    } on PlatformException catch (e) {
      return RecaptchaResult(
        success: false,
        errorMessage: e.message ?? 'Biometric authentication error',
      );
    }
  }

  @override
  Future<void> startBehavioralAnalysis() async {
    try {
      await methodChannel.invokeMethod('startBehavioralAnalysis');
    } on PlatformException catch (e) {
      debugPrint('Failed to start behavioral analysis: ${e.message}');
    }
  }

  @override
  Future<RecaptchaResult> stopBehavioralAnalysis() async {
    try {
      final result = await methodChannel.invokeMethod('stopBehavioralAnalysis');
      if (result != null && result is Map) {
        try {
          final resultMap = Map<String, dynamic>.from(result);
          return RecaptchaResult.fromMap(resultMap);
        } catch (e) {
          debugPrint('Error converting result map: $e');
          debugPrint('Result type: ${result.runtimeType}');
          debugPrint('Result content: $result');
          return const RecaptchaResult(
            success: false,
            errorMessage: 'Failed to parse behavioral analysis result',
          );
        }
      }
      return const RecaptchaResult(
        success: false,
        errorMessage: 'Behavioral analysis failed',
      );
    } on PlatformException catch (e) {
      return RecaptchaResult(
        success: false,
        errorMessage: e.message ?? 'Behavioral analysis error',
      );
    }
  }

  @override
  Future<String> getDeviceFingerprint() async {
    try {
      final result = await methodChannel.invokeMethod<String>(
        'getDeviceFingerprint',
      );
      return result ?? '';
    } on PlatformException catch (e) {
      debugPrint('Failed to get device fingerprint: ${e.message}');
      return '';
    }
  }

  @override
  Future<void> reset() async {
    try {
      await methodChannel.invokeMethod('reset');
    } on PlatformException catch (e) {
      debugPrint('Failed to reset reCAPTCHA: ${e.message}');
    }
  }
}
