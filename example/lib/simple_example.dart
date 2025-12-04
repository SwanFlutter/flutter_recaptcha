import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

/// Simple example showing basic usage of Flutter reCAPTCHA plugin
class SimpleRecaptchaExample extends StatefulWidget {
  const SimpleRecaptchaExample({super.key});

  @override
  State<SimpleRecaptchaExample> createState() => _SimpleRecaptchaExampleState();
}

class _SimpleRecaptchaExampleState extends State<SimpleRecaptchaExample> {
  final _recaptcha = FlutterRecaptcha.instance;
  String _status = 'Not initialized';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple reCAPTCHA Example')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Status: $_status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _initializeRecaptcha,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Initialize reCAPTCHA'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _performVerification,
                child: const Text('Verify with Smart Challenge'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkBiometric,
                child: const Text('Check Biometric Availability'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _getFingerprint,
                child: const Text('Get Device Fingerprint'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initializeRecaptcha() async {
    setState(() {
      _isLoading = true;
      _status = 'Initializing...';
    });

    try {
      final config = RecaptchaConfig(
        siteKey: 'your-site-key-here', // Replace with your actual site key
        type: RecaptchaType.smart,
        enableBiometric: true,
        enableBehavioralAnalysis: true,
        enableDeviceFingerprinting: true,
      );

      final success = await _recaptcha.initialize(config);

      setState(() {
        _status =
            success ? 'Initialized successfully!' : 'Failed to initialize';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performVerification() async {
    if (!_recaptcha.isInitialized) {
      setState(() {
        _status = 'Please initialize reCAPTCHA first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Verifying...';
    });

    try {
      final result = await _recaptcha.verify(action: 'login');

      setState(() {
        _status =
            result.success
                ? 'Verification successful! Score: ${result.score?.toStringAsFixed(2)}'
                : 'Verification failed: ${result.errorMessage}';
      });

      if (result.success) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      setState(() {
        _status = 'Error during verification: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkBiometric() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking biometric availability...';
    });

    try {
      final isAvailable = await _recaptcha.isBiometricAvailable();

      setState(() {
        _status =
            isAvailable
                ? 'Biometric authentication is available!'
                : 'Biometric authentication is not available';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking biometric: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getFingerprint() async {
    setState(() {
      _isLoading = true;
      _status = 'Generating device fingerprint...';
    });

    try {
      final fingerprint = await _recaptcha.getDeviceFingerprint();

      setState(() {
        _status = 'Device fingerprint: ${fingerprint.substring(0, 16)}...';
      });
    } catch (e) {
      setState(() {
        _status = 'Error getting fingerprint: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(RecaptchaResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Verification Successful!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score: ${result.score?.toStringAsFixed(3)}'),
                Text('Type: ${result.challengeType}'),
                if (result.token != null)
                  Text('Token: ${result.token!.substring(0, 20)}...'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
