import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

class RotationCaptchaDemoPage extends StatefulWidget {
  const RotationCaptchaDemoPage({super.key});

  @override
  State<RotationCaptchaDemoPage> createState() =>
      _RotationCaptchaDemoPageState();
}

class _RotationCaptchaDemoPageState extends State<RotationCaptchaDemoPage> {
  String _status = 'Click the button to start verification';
  Color _statusColor = Colors.grey;

  void _showRotationCaptcha() {
    setState(() {
      _status = 'Rotate the inner circle to match the outer circle';
      _statusColor = Colors.blue;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: RotationCaptchaWidget(
          imagePath: 'assets/dog_outer.jpg',
          tolerance: 20.0,
          onSuccess: () {
            Navigator.of(context).pop();
            setState(() {
              _status = '✓ Verification successful!';
              _statusColor = Colors.green;
            });
          },
          onFailed: () {
            setState(() {
              _status = '✗ Verification failed. Try again.';
              _statusColor = Colors.red;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotation CAPTCHA Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _statusColor == Colors.green
                    ? Icons.check_circle
                    : _statusColor == Colors.red
                    ? Icons.error
                    : Icons.rotate_right,
                size: 80,
                color: _statusColor,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _statusColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _showRotationCaptcha,
                icon: const Icon(Icons.security),
                label: const Text('Start Verification'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How it works:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('1. Two circular images are displayed'),
                      Text('2. The inner circle is rotated randomly'),
                      Text('3. Drag the slider to rotate the inner circle'),
                      Text('4. Align the marks to complete verification'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
