import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

class NumberTriangleCaptchaDemo extends StatefulWidget {
  const NumberTriangleCaptchaDemo({Key? key}) : super(key: key);

  @override
  State<NumberTriangleCaptchaDemo> createState() => _NumberTriangleCaptchaDemoState();
}

class _NumberTriangleCaptchaDemoState extends State<NumberTriangleCaptchaDemo> {
  bool _isVerified = false;
  String _verificationResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Triangle Captcha Demo'),
        backgroundColor: Colors.blue,
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
                      'Number Triangle Challenge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This captcha presents a number triangle pattern. Users must find the sum of all numbers in the bottom row to verify they are human.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...const [
                      '• Dynamic triangle generation',
                      '• Pattern-based challenges',
                      '• Visual number highlighting',
                      '• Hint system',
                      '• Refresh capability',
                    ].map((feature) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 2),
                      child: Text('• $feature'),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            NumberTriangleCaptchaWidget(
              title: 'Solve the Number Triangle',
              primaryColor: Colors.blue,
              size: 45,
              onVerified: (success) {
                setState(() {
                  _isVerified = success;
                  _verificationResult = success
                      ? '✅ Number Triangle verification successful!'
                      : '❌ Verification failed';
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
                        _isVerified ? Icons.check_circle : Icons.error,
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
                      '1. A number triangle is displayed with 4 rows\n'
                      '2. Each number follows a mathematical pattern\n'
                      '3. The bottom row is highlighted in orange\n'
                      '4. User must calculate the sum of bottom row numbers\n'
                      '5. Enter the answer and click Verify\n'
                      '6. Success indicates human interaction',
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
