// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'flutter_recaptcha_platform_interface.dart';

/// A web implementation of the FlutterRecaptchaPlatform of the FlutterRecaptcha plugin.
class FlutterRecaptchaWeb extends FlutterRecaptchaPlatform {
  /// Constructs a FlutterRecaptchaWeb
  FlutterRecaptchaWeb();

  RecaptchaConfig? _config;
  DateTime? _behavioralStartTime;
  final List<Map<String, dynamic>> _behavioralData = [];

  static void registerWith(Registrar registrar) {
    FlutterRecaptchaPlatform.instance = FlutterRecaptchaWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  @override
  Future<bool> initialize(RecaptchaConfig config) async {
    _config = config;
    return true;
  }

  @override
  Future<RecaptchaResult> verify({String? action}) async {
    // Simulate verification process
    final random = Random();
    final score =
        0.7 + (random.nextDouble() * 0.3); // Random score between 0.7-1.0
    final success = score > 0.8;

    return RecaptchaResult(
      success: success,
      token:
          success ? 'web_token_${DateTime.now().millisecondsSinceEpoch}' : null,
      score: score,
      challengeType: 'traditional',
      metadata: {
        'platform': 'web',
        'userAgent': web.window.navigator.userAgent,
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<bool> isBiometricAvailable() async {
    // For web platforms, biometric authentication is not reliably available
    // We return false to ensure pattern challenges are used instead
    return false;
  }

  @override
  Future<RecaptchaResult> authenticateWithBiometric() async {
    if (!await isBiometricAvailable()) {
      return const RecaptchaResult(
        success: false,
        errorMessage: 'Biometric authentication not available',
      );
    }

    try {
      // Simplified WebAuthn implementation
      // In a real implementation, you would use proper WebAuthn APIs
      return RecaptchaResult(
        success: true,
        token: 'biometric_token_${DateTime.now().millisecondsSinceEpoch}',
        score: 1.0,
        challengeType: 'biometric',
        metadata: {
          'platform': 'web',
          'biometricType': 'webauthn',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      return RecaptchaResult(
        success: false,
        errorMessage: 'Biometric authentication failed: $e',
      );
    }
  }

  @override
  Future<void> startBehavioralAnalysis() async {
    _behavioralStartTime = DateTime.now();
    _behavioralData.clear();

    // Simulate collecting behavioral data
    _simulateBehavioralData();
  }

  @override
  Future<RecaptchaResult> stopBehavioralAnalysis() async {
    if (_behavioralStartTime == null) {
      return const RecaptchaResult(
        success: false,
        errorMessage: 'Behavioral analysis not started',
      );
    }

    final duration = DateTime.now().difference(_behavioralStartTime!);
    final score = _calculateBehavioralScore(duration);

    return RecaptchaResult(
      success: score > 0.6,
      token:
          score > 0.6
              ? 'behavioral_token_${DateTime.now().millisecondsSinceEpoch}'
              : null,
      score: score,
      challengeType: 'behavioral',
      metadata: {
        'platform': 'web',
        'duration': duration.inMilliseconds,
        'dataPoints': _behavioralData.length,
        'patterns': _analyzeBehavioralPatterns(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<String> getDeviceFingerprint() async {
    final fingerprint = <String, dynamic>{
      'userAgent': web.window.navigator.userAgent,
      'language': web.window.navigator.language,
      'platform': web.window.navigator.platform,
      'cookieEnabled': web.window.navigator.cookieEnabled,
      'onLine': web.window.navigator.onLine,
      'screenWidth': web.window.screen.width,
      'screenHeight': web.window.screen.height,
      'colorDepth': web.window.screen.colorDepth,
      'pixelDepth': web.window.screen.pixelDepth,
      'timezone': DateTime.now().timeZoneName,
      'timezoneOffset': DateTime.now().timeZoneOffset.inMinutes,
    };

    // Simple hash of the fingerprint data
    final fingerprintString = jsonEncode(fingerprint);
    return _simpleHash(fingerprintString);
  }

  @override
  Future<void> reset() async {
    _config = null;
    _behavioralStartTime = null;
    _behavioralData.clear();
  }

  void _simulateBehavioralData() {
    // Simulate some behavioral data points
    final random = Random();
    for (int i = 0; i < 10; i++) {
      _behavioralData.add({
        'type': 'interaction',
        'x': random.nextInt(1000),
        'y': random.nextInt(1000),
        'timestamp': DateTime.now().millisecondsSinceEpoch + (i * 100),
      });
    }
  }

  double _calculateBehavioralScore(Duration duration) {
    double score = 0.5; // Base score

    if (duration.inMilliseconds > 1000) score += 0.2; // More than 1 second
    if (duration.inMilliseconds < 10000) score += 0.2; // Less than 10 seconds
    if (_behavioralData.length > 10) score += 0.1; // Some interaction data

    // Analyze mouse movement patterns
    final mouseEvents =
        _behavioralData.where((e) => e['type'] == 'mousemove').toList();
    if (mouseEvents.length > 5) {
      score += 0.1; // Natural mouse movement
    }

    return score.clamp(0.0, 1.0);
  }

  Map<String, dynamic> _analyzeBehavioralPatterns() {
    final interactionEvents =
        _behavioralData.where((e) => e['type'] == 'interaction').toList();

    return {
      'totalEvents': _behavioralData.length,
      'interactionEvents': interactionEvents.length,
      'averageSpeed': _calculateAverageSpeed(interactionEvents),
    };
  }

  double _calculateAverageSpeed(List<Map<String, dynamic>> events) {
    if (events.length < 2) return 0.0;

    double totalDistance = 0.0;
    int totalTime = 0;

    for (int i = 1; i < events.length; i++) {
      final prev = events[i - 1];
      final curr = events[i];

      final dx = (curr['x'] as int) - (prev['x'] as int);
      final dy = (curr['y'] as int) - (prev['y'] as int);
      final distance = sqrt(dx * dx + dy * dy);

      final timeDiff = (curr['timestamp'] as int) - (prev['timestamp'] as int);

      totalDistance += distance;
      totalTime += timeDiff;
    }

    return totalTime > 0 ? totalDistance / totalTime : 0.0;
  }

  String _simpleHash(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xffffffff;
    }
    return hash.toRadixString(16);
  }
}
