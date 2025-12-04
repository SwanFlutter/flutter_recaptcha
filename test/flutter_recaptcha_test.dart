import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';
import 'package:flutter_recaptcha/flutter_recaptcha_platform_interface.dart';
import 'package:flutter_recaptcha/flutter_recaptcha_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterRecaptchaPlatform
    with MockPlatformInterfaceMixin
    implements FlutterRecaptchaPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<RecaptchaResult> authenticateWithBiometric() {
    // TODO: implement authenticateWithBiometric
    throw UnimplementedError();
  }

  @override
  Future<String> getDeviceFingerprint() {
    // TODO: implement getDeviceFingerprint
    throw UnimplementedError();
  }

  @override
  Future<bool> initialize(RecaptchaConfig config) {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<bool> isBiometricAvailable() {
    // TODO: implement isBiometricAvailable
    throw UnimplementedError();
  }

  @override
  Future<void> reset() {
    // TODO: implement reset
    throw UnimplementedError();
  }

  @override
  Future<void> startBehavioralAnalysis() {
    // TODO: implement startBehavioralAnalysis
    throw UnimplementedError();
  }

  @override
  Future<RecaptchaResult> stopBehavioralAnalysis() {
    // TODO: implement stopBehavioralAnalysis
    throw UnimplementedError();
  }

  @override
  Future<RecaptchaResult> verify({String? action}) {
    // TODO: implement verify
    throw UnimplementedError();
  }
}

void main() {
  final FlutterRecaptchaPlatform initialPlatform = FlutterRecaptchaPlatform.instance;

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
