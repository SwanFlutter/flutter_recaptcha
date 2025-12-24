library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_recaptcha_platform_interface.dart';
import 'src/tools/challenge_difficulty.dart';
import 'src/tools/recaptcha_config.dart';
import 'src/tools/recaptcha_result.dart';
import 'src/tools/recaptcha_type.dart';
import 'src/widgets/fingerprint_captcha_widget.dart';
import 'src/widgets/grid_captcha_widget.dart';
import 'src/widgets/math_puzzle_captcha_widget.dart';
import 'src/widgets/number_triangle_captcha_widget.dart';
import 'src/widgets/rotation_captcha_widget.dart';
import 'src/widgets/shape_matching_captcha_widget.dart';
import 'src/widgets/slider_captcha_widget.dart';
import 'src/widgets/text_captcha_widget.dart';

export 'package:flutter_recaptcha/src/tools/recaptcha_config.dart';
export 'package:flutter_recaptcha/src/tools/recaptcha_result.dart';

export 'src/tools/challenge_difficulty.dart';
export 'src/tools/recaptcha_type.dart';
// Export all public APIs

export 'src/widgets/fingerprint_captcha_widget.dart';
export 'src/widgets/grid_captcha_widget.dart';
export 'src/widgets/math_puzzle_captcha_widget.dart';
export 'src/widgets/number_triangle_captcha_widget.dart';
export 'src/widgets/recaptcha_widget.dart';
export 'src/widgets/rotation_captcha_widget.dart';
export 'src/widgets/shape_matching_captcha_widget.dart';
export 'src/widgets/slider_captcha_widget.dart';
export 'src/widgets/text_captcha_widget.dart';

/// Main class for Flutter reCAPTCHA plugin
class FlutterRecaptcha {
  static FlutterRecaptcha? _instance;
  static FlutterRecaptcha get instance => _instance ??= FlutterRecaptcha._();

  FlutterRecaptcha._();

  RecaptchaConfig? _config;
  bool _isInitialized = false;
  Timer? _behavioralTimer;
  final List<Map<String, dynamic>> _behavioralData = [];

  /// Get platform version
  Future<String?> getPlatformVersion() {
    return FlutterRecaptchaPlatform.instance.getPlatformVersion();
  }

  /// Initialize reCAPTCHA with configuration
  Future<bool> initialize(RecaptchaConfig config) async {
    _config = config;
    final result = await FlutterRecaptchaPlatform.instance.initialize(config);
    _isInitialized = result;
    return result;
  }

  /// Check if reCAPTCHA is initialized
  bool get isInitialized => _isInitialized;

  /// Execute reCAPTCHA verification with smart challenge selection
  Future<RecaptchaResult> verify({String? action}) async {
    if (!_isInitialized || _config == null) {
      return const RecaptchaResult(
        success: false,
        errorMessage: 'reCAPTCHA not initialized',
      );
    }

    try {
      // Smart challenge selection based on configuration
      switch (_config!.type) {
        case RecaptchaType.invisible:
          return await _performInvisibleVerification(action);
        case RecaptchaType.biometric:
          return await _performBiometricVerification();
        case RecaptchaType.behavioral:
          return await _performBehavioralVerification();
        case RecaptchaType.smart:
          return await _performSmartVerification(action);
        case RecaptchaType.traditional:
          return await FlutterRecaptchaPlatform.instance.verify(action: action);
      }
    } catch (e) {
      return RecaptchaResult(
        success: false,
        errorMessage: 'Verification failed: $e',
      );
    }
  }

  /// Perform invisible verification
  Future<RecaptchaResult> _performInvisibleVerification(String? action) async {
    // Combine device fingerprinting with behavioral analysis
    final fingerprint = await getDeviceFingerprint();

    if (_config!.enableBehavioralAnalysis) {
      await startBehavioralAnalysis();
      // Wait a bit to collect behavioral data
      await Future.delayed(const Duration(seconds: 2));
      final behavioralResult = await stopBehavioralAnalysis();

      if (behavioralResult.success && (behavioralResult.score ?? 0) > 0.7) {
        return RecaptchaResult(
          success: true,
          token: _generateToken(),
          score: behavioralResult.score,
          challengeType: 'invisible',
          metadata: {
            'fingerprint': fingerprint,
            'behavioral': behavioralResult.metadata,
          },
        );
      }
    }

    // Fallback to platform verification
    return await FlutterRecaptchaPlatform.instance.verify(action: action);
  }

  /// Perform biometric verification
  Future<RecaptchaResult> _performBiometricVerification() async {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      return const RecaptchaResult(
        success: false,
        errorMessage: 'Biometric authentication not available',
      );
    }

    return await FlutterRecaptchaPlatform.instance.authenticateWithBiometric();
  }

  /// Perform behavioral verification
  Future<RecaptchaResult> _performBehavioralVerification() async {
    await startBehavioralAnalysis();

    // Wait for user interaction
    await Future.delayed(const Duration(seconds: 5));

    return await stopBehavioralAnalysis();
  }

  /// Perform smart verification (adaptive)
  Future<RecaptchaResult> _performSmartVerification(String? action) async {
    // First try invisible verification
    final invisibleResult = await _performInvisibleVerification(action);

    if (invisibleResult.success && (invisibleResult.score ?? 0) > 0.8) {
      return invisibleResult;
    }

    // If biometric is available and enabled, try it
    if (_config!.enableBiometric && await isBiometricAvailable()) {
      final biometricResult = await _performBiometricVerification();
      if (biometricResult.success) {
        return biometricResult;
      }
    }

    // Fallback to traditional challenge
    return await FlutterRecaptchaPlatform.instance.verify(action: action);
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() {
    return FlutterRecaptchaPlatform.instance.isBiometricAvailable();
  }

  /// Start behavioral analysis
  Future<void> startBehavioralAnalysis() async {
    _behavioralData.clear();
    await FlutterRecaptchaPlatform.instance.startBehavioralAnalysis();

    // Start collecting behavioral data
    _behavioralTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) => _collectBehavioralData(),
    );
  }

  /// Stop behavioral analysis
  Future<RecaptchaResult> stopBehavioralAnalysis() async {
    _behavioralTimer?.cancel();
    _behavioralTimer = null;

    final result = await FlutterRecaptchaPlatform.instance
        .stopBehavioralAnalysis();

    // Enhance result with collected data
    if (_behavioralData.isNotEmpty) {
      final score = _calculateBehavioralScore();
      return RecaptchaResult(
        success: score > 0.6,
        token: score > 0.6 ? _generateToken() : null,
        score: score,
        challengeType: 'behavioral',
        metadata: {
          'dataPoints': _behavioralData.length,
          'patterns': _analyzeBehavioralPatterns(),
          ...result.metadata ?? {},
        },
      );
    }

    return result;
  }

  /// Get device fingerprint
  Future<String> getDeviceFingerprint() {
    return FlutterRecaptchaPlatform.instance.getDeviceFingerprint();
  }

  /// Reset reCAPTCHA state
  Future<void> reset() async {
    _behavioralTimer?.cancel();
    _behavioralTimer = null;
    _behavioralData.clear();
    await FlutterRecaptchaPlatform.instance.reset();
  }

  /// Collect behavioral data (mock implementation)
  void _collectBehavioralData() {
    _behavioralData.add({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': 'interaction',
      // In real implementation, this would collect actual user interaction data
    });
  }

  /// Calculate behavioral score based on collected data
  double _calculateBehavioralScore() {
    if (_behavioralData.isEmpty) return 0.0;

    // Simple scoring algorithm - in real implementation this would be more sophisticated
    final dataPoints = _behavioralData.length;
    final timeSpan =
        _behavioralData.last['timestamp'] - _behavioralData.first['timestamp'];

    // Score based on interaction patterns
    double score = 0.5; // Base score

    if (dataPoints > 10) score += 0.2;
    if (timeSpan > 1000) score += 0.2; // More than 1 second of interaction
    if (dataPoints / (timeSpan / 1000) < 50) score += 0.1; // Not too fast

    return score.clamp(0.0, 1.0);
  }

  /// Analyze behavioral patterns
  Map<String, dynamic> _analyzeBehavioralPatterns() {
    return {
      'totalInteractions': _behavioralData.length,
      'duration': _behavioralData.isNotEmpty
          ? _behavioralData.last['timestamp'] -
                _behavioralData.first['timestamp']
          : 0,
      'averageInterval': _behavioralData.length > 1
          ? (_behavioralData.last['timestamp'] -
                    _behavioralData.first['timestamp']) /
                _behavioralData.length
          : 0,
    };
  }

  /// Generate a mock token
  String _generateToken() {
    return 'recaptcha_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Widget Factory Methods

  /// Creates a Grid CAPTCHA widget for pattern recognition challenges
  ///
  /// Returns a widget that displays a 3x3 grid with various challenges
  static Widget gridCaptcha({
    double width = 300,
    VoidCallback? onSuccess,
    VoidCallback? onFailed,
    String? title,
  }) {
    return GridCaptchaWidget(
      width: width,
      onSuccess: onSuccess,
      onFailed: onFailed,
      title: title,
    );
  }

  /// Creates a Math Puzzle CAPTCHA widget
  ///
  /// Returns a widget that presents mathematical equations to solve
  static Widget mathPuzzleCaptcha({
    required Function(bool) onVerified,
    String? title,
    Color? primaryColor,
    ChallengeDifficulty difficulty = ChallengeDifficulty.medium,
  }) {
    return MathPuzzleCaptchaWidget(
      onVerified: onVerified,
      title: title,
      primaryColor: primaryColor,
      difficulty: difficulty,
    );
  }

  /// Creates a Number Triangle CAPTCHA widget
  ///
  /// Returns a widget that displays a number triangle pattern challenge
  static Widget numberTriangleCaptcha({
    required Function(bool) onVerified,
    String? title,
    Color? primaryColor,
    double? size,
  }) {
    return NumberTriangleCaptchaWidget(
      onVerified: onVerified,
      title: title,
      primaryColor: primaryColor,
      size: size,
    );
  }

  /// Creates a Rotation CAPTCHA widget
  ///
  /// Returns a widget that requires rotating an inner circle to align with outer circle
  static Widget rotationCaptcha({
    ImageProvider? imageProvider,
    String? imagePath,
    double width = 240,
    double height = 240,
    double? sliderWidth,
    double innerRadiusRatio = 0.66,
    VoidCallback? onSuccess,
    VoidCallback? onFailed,
    double tolerance = 10.0,
    Duration animationDuration = const Duration(milliseconds: 500),
  }) {
    return RotationCaptchaWidget(
      imageProvider: imageProvider,
      imagePath: imagePath,
      width: width,
      height: height,
      sliderWidth: sliderWidth,
      innerRadiusRatio: innerRadiusRatio,
      onSuccess: onSuccess,
      onFailed: onFailed,
      tolerance: tolerance,
      animationDuration: animationDuration,
    );
  }

  /// Creates a Shape Matching CAPTCHA widget
  ///
  /// Returns a widget that requires matching shapes by type and color
  static Widget shapeMatchingCaptcha({
    required Function(bool) onVerified,
    String? title,
    Color? primaryColor,
    double? size,
  }) {
    return ShapeMatchingCaptchaWidget(
      onVerified: onVerified,
      title: title,
      primaryColor: primaryColor,
      size: size,
    );
  }

  /// Creates a Slider CAPTCHA widget
  ///
  /// Returns a widget that requires sliding a puzzle piece to match position
  static Widget sliderCaptcha({
    required ImageProvider imageProvider,
    double width = 300,
    double height = 150,
    double sliderWidth = 300,
    VoidCallback? onSuccess,
    VoidCallback? onFailed,
    double tolerance = 0.05,
  }) {
    return SliderCaptchaWidget(
      imageProvider: imageProvider,
      width: width,
      height: height,
      sliderWidth: sliderWidth,
      onSuccess: onSuccess,
      onFailed: onFailed,
      tolerance: tolerance,
    );
  }

  /// Creates a Text CAPTCHA widget
  ///
  /// Returns a widget that displays a text code to be entered
  static Widget textCaptcha({
    double width = 300,
    double height = 200,
    int length = 5,
    VoidCallback? onSuccess,
    VoidCallback? onFailed,
    TextStyle? codeStyle,
    InputDecoration? inputDecoration,
  }) {
    return TextCaptchaWidget(
      width: width,
      height: height,
      length: length,
      onSuccess: onSuccess,
      onFailed: onFailed,
      codeStyle: codeStyle,
      inputDecoration: inputDecoration,
    );
  }

  /// Creates a Fingerprint CAPTCHA widget
  ///
  /// Returns a widget that simulates fingerprint scanning verification
  static Widget fingerprintCaptcha({
    required Function(bool) onVerified,
    String? title,
    Color? primaryColor,
    double? size,
  }) {
    return FingerprintCaptchaWidget(
      onVerified: onVerified,
      title: title,
      primaryColor: primaryColor,
      size: size,
    );
  }
}
