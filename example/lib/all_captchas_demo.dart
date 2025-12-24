import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';
import 'package:flutter_recaptcha/flutter_recaptcha_platform_interface.dart';
import 'package:flutter_recaptcha_example/shape_matching_captcha_demo.dart';

class AllCaptchasDemo extends StatefulWidget {
  const AllCaptchasDemo({Key? key}) : super(key: key);

  @override
  State<AllCaptchasDemo> createState() => _AllCaptchasDemoState();
}

class _AllCaptchasDemoState extends State<AllCaptchasDemo> {
  final Map<String, bool> _verificationResults = {};
  int _completedVerifications = 0;

  void _updateResult(String captchaType, bool success) {
    setState(() {
      _verificationResults[captchaType] = success;
      if (success) {
        _completedVerifications++;
      }
    });
  }

  Widget _buildCaptchaCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Widget captcha,
    required String key,
  }) {
    final isVerified = _verificationResults[key] ?? false;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isVerified)
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            captcha,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All CAPTCHAs Demo'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (_completedVerifications > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Chip(
                  label: Text('$_completedVerifications/$_verificationResults.length'),
                  backgroundColor: Colors.green,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.security,
                      size: 48,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete All Security Verifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progress: $_completedVerifications/${_verificationResults.length}',
                      style: TextStyle(color: Colors.indigo.shade700),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _verificationResults.isEmpty 
                          ? 0.0 
                          : _completedVerifications / _verificationResults.length,
                      backgroundColor: Colors.indigo.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Number Triangle Captcha
            _buildCaptchaCard(
              title: 'Number Triangle',
              description: 'Solve the mathematical pattern',
              icon: Icons.change_history,
              color: Colors.blue,
              key: 'number_triangle',
              captcha: NumberTriangleCaptchaWidget(
                title: 'Find the sum of bottom row',
                primaryColor: Colors.blue,
                size: 40,
                onVerified: (success) => _updateResult('number_triangle', success),
              ),
            ),
            
            // Fingerprint Captcha
            _buildCaptchaCard(
              title: 'Fingerprint Scan',
              description: 'Biometric verification simulation',
              icon: Icons.fingerprint,
              color: Colors.purple,
              key: 'fingerprint',
              captcha: FingerprintCaptchaWidget(
                title: 'Verify Your Identity',
                primaryColor: Colors.purple,
                size: 100,
                onVerified: (success) => _updateResult('fingerprint', success),
              ),
            ),
            
            // Math Puzzle Captcha
            _buildCaptchaCard(
              title: 'Math Puzzle',
              description: 'Solve mathematical challenges',
              icon: Icons.calculate,
              color: Colors.orange,
              key: 'math_puzzle',
              captcha: MathPuzzleCaptchaWidget(
                title: 'Solve the equation',
                primaryColor: Colors.orange,
                difficulty: ChallengeDifficulty.medium,
                onVerified: (success) => _updateResult('math_puzzle', success),
              ),
            ),
            
            // Shape Matching Captcha (Dialog)
            _buildCaptchaCard(
              title: 'Shape Matching',
              description: 'Select shapes as instructed',
              icon: Icons.category,
              color: Colors.teal,
              key: 'shape_matching',
              captcha: Column(
                children: [
                  const Text(
                    'Click the button to open shape matching dialog',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => ShapeMatchingDialog(
                          onVerified: (success) {
                            Navigator.of(context).pop();
                            _updateResult('shape_matching', success);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Dialog'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Success Message
            if (_completedVerifications == _verificationResults.length && _completedVerifications > 0)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Verifications Complete!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'You have successfully completed all security challenges.',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Reset Button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _verificationResults.clear();
                  _completedVerifications = 0;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset All Verifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Random Captcha Challenge Demo
class RandomCaptchaChallenge extends StatefulWidget {
  const RandomCaptchaChallenge({Key? key}) : super(key: key);

  @override
  State<RandomCaptchaChallenge> createState() => _RandomCaptchaChallengeState();
}

class _RandomCaptchaChallengeState extends State<RandomCaptchaChallenge> {
  Widget _currentCaptcha = Container();
  int _attempts = 0;
  bool _isCompleted = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateRandomCaptcha();
  }

  void _generateRandomCaptcha() {
    final captchaType = _random.nextInt(4);
    
    setState(() {
      switch (captchaType) {
        case 0:
          _currentCaptcha = NumberTriangleCaptchaWidget(
            title: 'Random Challenge: Number Triangle',
            primaryColor: Colors.blue,
            onVerified: _handleVerification,
          );
          break;
        case 1:
          _currentCaptcha = FingerprintCaptchaWidget(
            title: 'Random Challenge: Fingerprint',
            primaryColor: Colors.purple,
            size: 120,
            onVerified: _handleVerification,
          );
          break;
        case 2:
          _currentCaptcha = MathPuzzleCaptchaWidget(
            title: 'Random Challenge: Math Puzzle',
            primaryColor: Colors.orange,
            difficulty: ChallengeDifficulty.values[_random.nextInt(3)],
            onVerified: _handleVerification,
          );
          break;
        case 3:
          _currentCaptcha = ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => ShapeMatchingDialog(
                  onVerified: (success) {
                    Navigator.of(context).pop();
                    _handleVerification(success);
                  },
                ),
              );
            },
            child: const Text('Start Shape Matching Challenge'),
          );
          break;
      }
    });
  }

  void _handleVerification(bool success) {
    setState(() {
      _attempts++;
      if (success) {
        _isCompleted = true;
      } else {
        // Generate a new captcha on failure
        Future.delayed(const Duration(seconds: 1), _generateRandomCaptcha);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random CAPTCHA Challenge'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Challenge Info
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.shuffle, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Random Challenge Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text('Attempts: $_attempts'),
                    if (_isCompleted)
                      const Text(
                        '✅ Challenge Complete!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Current Captcha
            Expanded(
              child: _isCompleted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events, size: 64, color: Colors.amber  ),
                          SizedBox(height: 16),
                          Text(
                            'Congratulations!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('You completed the random challenge in ${_attempts} attempts'),
                        ],
                      ),
                    )
                  : _currentCaptcha,
            ),
            
            if (!_isCompleted && _attempts > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: _generateRandomCaptcha,
                  child: const Text('Skip This Challenge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
