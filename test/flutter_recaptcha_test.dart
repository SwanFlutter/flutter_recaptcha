import 'package:flutter_recaptcha/flutter_recaptcha.dart';
import 'package:flutter_recaptcha/flutter_recaptcha_method_channel.dart';
import 'package:flutter_recaptcha/flutter_recaptcha_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterRecaptchaPlatform
    with MockPlatformInterfaceMixin
    implements FlutterRecaptchaPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<RecaptchaResult> authenticateWithBiometric() {
    throw UnimplementedError();
  }

  @override
  Future<String> getDeviceFingerprint() {
    throw UnimplementedError();
  }

  @override
  Future<bool> initialize(RecaptchaConfig config) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isBiometricAvailable() {
    throw UnimplementedError();
  }

  @override
  Future<void> reset() {
    throw UnimplementedError();
  }

  @override
  Future<void> startBehavioralAnalysis() {
    throw UnimplementedError();
  }

  @override
  Future<RecaptchaResult> stopBehavioralAnalysis() {
    throw UnimplementedError();
  }

  @override
  Future<RecaptchaResult> verify({String? action}) {
    throw UnimplementedError();
  }
}

void main() {
  final FlutterRecaptchaPlatform initialPlatform =
      FlutterRecaptchaPlatform.instance;

  test('$MethodChannelFlutterRecaptcha is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterRecaptcha>());
  });

  test('getPlatformVersion', () async {
    FlutterRecaptcha flutterRecaptchaPlugin = FlutterRecaptcha.instance;
    MockFlutterRecaptchaPlatform fakePlatform = MockFlutterRecaptchaPlatform();
    FlutterRecaptchaPlatform.instance = fakePlatform;

    expect(await flutterRecaptchaPlugin.getPlatformVersion(), '42');
  });
}
