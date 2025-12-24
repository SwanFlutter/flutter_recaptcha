// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter_recaptcha/src/tools/challenge_difficulty.dart';
import 'package:flutter_recaptcha/src/tools/recaptcha_type.dart';

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
    return <String, dynamic>{
      'siteKey': siteKey,
      'type': type.toString(),
      'difficulty': difficulty.toString(),
      'enableBiometric': enableBiometric,
      'enableBehavioralAnalysis': enableBehavioralAnalysis,
      'enableDeviceFingerprinting': enableDeviceFingerprinting,
      'timeout': timeout.inMilliseconds,
      'theme': theme,
      'language': language,
    };
  }

  RecaptchaConfig copyWith({
    String? siteKey,
    RecaptchaType? type,
    ChallengeDifficulty? difficulty,
    bool? enableBiometric,
    bool? enableBehavioralAnalysis,
    bool? enableDeviceFingerprinting,
    Duration? timeout,
    String? theme,
    String? language,
  }) {
    return RecaptchaConfig(
      siteKey: siteKey ?? this.siteKey,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      enableBehavioralAnalysis: enableBehavioralAnalysis ?? this.enableBehavioralAnalysis,
      enableDeviceFingerprinting: enableDeviceFingerprinting ?? this.enableDeviceFingerprinting,
      timeout: timeout ?? this.timeout,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }

  factory RecaptchaConfig.fromMap(Map<String, dynamic> map) {
    return RecaptchaConfig(
      siteKey: map['siteKey'] as String,
      type: RecaptchaType.values.firstWhere((e) => e.toString() == map['type']),
      difficulty: ChallengeDifficulty.values.firstWhere((e) => e.toString() == map['difficulty']),
      enableBiometric: map['enableBiometric'] as bool,
      enableBehavioralAnalysis: map['enableBehavioralAnalysis'] as bool,
      enableDeviceFingerprinting: map['enableDeviceFingerprinting'] as bool,
      timeout: Duration(milliseconds: map['timeout'] as int),
      theme: map['theme'] != null ? map['theme'] as String : null,
      language: map['language'] != null ? map['language'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RecaptchaConfig.fromJson(String source) => RecaptchaConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RecaptchaConfig(siteKey: $siteKey, type: $type, difficulty: $difficulty, enableBiometric: $enableBiometric, enableBehavioralAnalysis: $enableBehavioralAnalysis, enableDeviceFingerprinting: $enableDeviceFingerprinting, timeout: $timeout, theme: $theme, language: $language)';
  }

  @override
  bool operator ==(covariant RecaptchaConfig other) {
    if (identical(this, other)) return true;
  
    return 
      other.siteKey == siteKey &&
      other.type == type &&
      other.difficulty == difficulty &&
      other.enableBiometric == enableBiometric &&
      other.enableBehavioralAnalysis == enableBehavioralAnalysis &&
      other.enableDeviceFingerprinting == enableDeviceFingerprinting &&
      other.timeout == timeout &&
      other.theme == theme &&
      other.language == language;
  }

  @override
  int get hashCode {
    return siteKey.hashCode ^
      type.hashCode ^
      difficulty.hashCode ^
      enableBiometric.hashCode ^
      enableBehavioralAnalysis.hashCode ^
      enableDeviceFingerprinting.hashCode ^
      timeout.hashCode ^
      theme.hashCode ^
      language.hashCode;
  }
}
