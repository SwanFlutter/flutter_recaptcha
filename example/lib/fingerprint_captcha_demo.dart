import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

class FingerprintCaptchaDemo extends StatefulWidget {
  const FingerprintCaptchaDemo({Key? key}) : super(key: key);

  @override
  State<FingerprintCaptchaDemo> createState() => _FingerprintCaptchaDemoState();
}

class _FingerprintCaptchaDemoState extends State<FingerprintCaptchaDemo> {
  bool _isVerified = false;
  String _verificationResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Captcha Demo'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fingerprint Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This captcha simulates fingerprint scanning with animated effects and progress tracking for biometric verification.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...const [
                      '• Animated fingerprint scanner',
                      '• Progress tracking with percentage',
                      '• Visual scanning effects',
                      '• Pulse animations',
                      '• Success/failure feedback',
                    ].map((feature) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 2),
                      child: Text('• $feature'),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FingerprintCaptchaWidget(
              title: 'Biometric Verification',
              primaryColor: Colors.purple,
              size: 120,
              onVerified: (success) {
                setState(() {
                  _isVerified = success;
                  _verificationResult = success
                      ? '✅ Fingerprint verification successful!'
                      : '❌ Biometric verification failed';
                });
              },
            ),
            const SizedBox(height: 20),
            if (_verificationResult.isNotEmpty)
              Card(
                color: _isVerified ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isVerified ? Icons.fingerprint : Icons.error,
                        color: _isVerified ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _verificationResult,
                          style: TextStyle(
                            color: _isVerified ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How it works:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Click "Start Scan" to begin fingerprint verification\n'
                      '2. Watch the animated scanning progress\n'
                      '3. The scanner simulates biometric analysis\n'
                      '4. Progress bar shows scanning completion\n'
                      '5. Success indicates verified biometric data\n'
                      '6. Can retry if verification fails',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
