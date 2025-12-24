import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_recaptcha_method_channel.dart';
import 'src/tools/recaptcha_config.dart';
import 'src/tools/recaptcha_result.dart';

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
