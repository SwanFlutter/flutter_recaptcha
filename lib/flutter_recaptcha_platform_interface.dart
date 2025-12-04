import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_recaptcha_method_channel.dart';

/// Enum for different types of reCAPTCHA challenges
enum RecaptchaType { invisible, biometric, behavioral, smart, traditional }

/// Enum for challenge difficulty levels
enum ChallengeDifficulty { easy, medium, hard, adaptive }

/// Result of reCAPTCHA verification
class RecaptchaResult {
  final bool success;
  final String? token;
  final double? score; // 0.0 to 1.0, higher is more human-like
  final String? challengeType;
  final Map<String, dynamic>? metadata;
  final String? errorMessage;

  const RecaptchaResult({
    required this.success,
    this.token,
    this.score,
    this.challengeType,
    this.metadata,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'token': token,
      'score': score,
      'challengeType': challengeType,
      'metadata': metadata,
      'errorMessage': errorMessage,
    };
  }

  factory RecaptchaResult.fromMap(Map<String, dynamic> map) {
    try {
      return RecaptchaResult(
        success: map['success'] ?? false,
        token: map['token']?.toString(),
        score: map['score']?.toDouble(),
        challengeType: map['challengeType']?.toString(),
        metadata:
            map['metadata'] is Map
                ? Map<String, dynamic>.from(map['metadata'])
                : null,
        errorMessage: map['errorMessage']?.toString(),
      );
    } catch (e) {
      debugPrint('Error in RecaptchaResult.fromMap: $e');
      debugPrint('Map content: $map');
      return RecaptchaResult(
        success: false,
        errorMessage: 'Failed to parse result: $e',
      );
    }
  }
}

/// Configuration for reCAPTCHA
class RecaptchaConfig {
  final String siteKey;
  final RecaptchaType type;
  final ChallengeDifficulty difficulty;
  final bool enableBiometric;
  final bool enableBehavioralAnalysis;
  final bool enableDeviceFingerprinting;
  final Duration timeout;
  final String? theme; // 'light' or 'dark'
  final String? language;

  const RecaptchaConfig({
    required this.siteKey,
    this.type = RecaptchaType.smart,
    this.difficulty = ChallengeDifficulty.adaptive,
    this.enableBiometric = true,
    this.enableBehavioralAnalysis = true,
    this.enableDeviceFingerprinting = true,
    this.timeout = const Duration(minutes: 2),
    this.theme = 'light',
    this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'siteKey': siteKey,
      'type': type.name,
      'difficulty': difficulty.name,
      'enableBiometric': enableBiometric,
      'enableBehavioralAnalysis': enableBehavioralAnalysis,
      'enableDeviceFingerprinting': enableDeviceFingerprinting,
      'timeout': timeout.inMilliseconds,
      'theme': theme,
      'language': language,
    };
  }
}

abstract class FlutterRecaptchaPlatform extends PlatformInterface {
  /// Constructs a FlutterRecaptchaPlatform.
  FlutterRecaptchaPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterRecaptchaPlatform _instance = MethodChannelFlutterRecaptcha();

  /// The default instance of [FlutterRecaptchaPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterRecaptcha].
  static FlutterRecaptchaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterRecaptchaPlatform] when
  /// they register themselves.
  static set instance(FlutterRecaptchaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Initialize reCAPTCHA with configuration
  Future<bool> initialize(RecaptchaConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Execute reCAPTCHA verification
  Future<RecaptchaResult> verify({String? action}) {
    throw UnimplementedError('verify() has not been implemented.');
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() {
    throw UnimplementedError(
      'isBiometricAvailable() has not been implemented.',
    );
  }

  /// Perform biometric authentication
  Future<RecaptchaResult> authenticateWithBiometric() {
    throw UnimplementedError(
      'authenticateWithBiometric() has not been implemented.',
    );
  }

  /// Start behavioral analysis
  Future<void> startBehavioralAnalysis() {
    throw UnimplementedError(
      'startBehavioralAnalysis() has not been implemented.',
    );
  }

  /// Stop behavioral analysis and get result
  Future<RecaptchaResult> stopBehavioralAnalysis() {
    throw UnimplementedError(
      'stopBehavioralAnalysis() has not been implemented.',
    );
  }

  /// Get device fingerprint
  Future<String> getDeviceFingerprint() {
    throw UnimplementedError(
      'getDeviceFingerprint() has not been implemented.',
    );
  }

  /// Reset reCAPTCHA state
  Future<void> reset() {
    throw UnimplementedError('reset() has not been implemented.');
  }
}
