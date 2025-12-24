// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

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
    return <String, dynamic>{
      'success': success,
      'token': token,
      'score': score,
      'challengeType': challengeType,
      'metadata': metadata,
      'errorMessage': errorMessage,
    };
  }

  factory RecaptchaResult.fromMap(Map<String, dynamic> map) {
    return RecaptchaResult(
      success: map['success'] as bool,
      token: map['token'] != null ? map['token'] as String : null,
      score: map['score'] != null ? map['score'] as double : null,
      challengeType: map['challengeType'] != null
          ? map['challengeType'] as String
          : null,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map<String, dynamic>)
          : null,
      errorMessage: map['errorMessage'] != null
          ? map['errorMessage'] as String
          : null,
    );
  }

  RecaptchaResult copyWith({
    bool? success,
    String? token,
    double? score,
    String? challengeType,
    Map<String, dynamic>? metadata,
    String? errorMessage,
  }) {
    return RecaptchaResult(
      success: success ?? this.success,
      token: token ?? this.token,
      score: score ?? this.score,
      challengeType: challengeType ?? this.challengeType,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String toJson() => json.encode(toMap());

  factory RecaptchaResult.fromJson(String source) =>
      RecaptchaResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RecaptchaResult(success: $success, token: $token, score: $score, challengeType: $challengeType, metadata: $metadata, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(covariant RecaptchaResult other) {
    if (identical(this, other)) return true;

    return other.success == success &&
        other.token == token &&
        other.score == score &&
        other.challengeType == challengeType &&
        mapEquals(other.metadata, metadata) &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        token.hashCode ^
        score.hashCode ^
        challengeType.hashCode ^
        metadata.hashCode ^
        errorMessage.hashCode;
  }
}
