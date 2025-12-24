import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

class TextCaptchaDemoPage extends StatefulWidget {
  const TextCaptchaDemoPage({super.key});

  @override
  State<TextCaptchaDemoPage> createState() => _TextCaptchaDemoPageState();
}

class _TextCaptchaDemoPageState extends State<TextCaptchaDemoPage> {
  String _status = 'Click to start verification';
  Color _statusColor = Colors.grey;

  void _showCaptchaDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Enter Security Code",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextCaptchaWidget(
                width: 280,
                height: 250,
                length: 5,
                onSuccess: () {
                  Navigator.pop(context);
                  setState(() {
                    _status = '✓ Verification successful!';
                    _statusColor = Colors.green;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verified!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                onFailed: () {
                  // Status handled inside widget or we can show snackbar
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text CAPTCHA Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _statusColor == Colors.green
                    ? Icons.check_circle
                    : _statusColor == Colors.red
                    ? Icons.error
                    : Icons.text_fields,
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

              ElevatedButton(
                onPressed: _showCaptchaDialog,
                child: const Text('Start Verification'),
              ),

              const SizedBox(height: 48),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• Random alphanumeric code generation'),
                      Text('• Visual noise (lines, rotation) to prevent OCR'),
                      Text('• Refresh capability'),
                      Text('• Simple text input verification'),
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
