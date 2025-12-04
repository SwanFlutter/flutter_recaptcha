library;

import 'dart:async';

import 'flutter_recaptcha_platform_interface.dart';

// Export all public APIs
export 'flutter_recaptcha_platform_interface.dart'
    show RecaptchaConfig, RecaptchaResult, RecaptchaType, ChallengeDifficulty;
export 'widgets/recaptcha_widget.dart';
export 'widgets/rotation_captcha_widget.dart';

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
}
