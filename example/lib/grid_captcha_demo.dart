import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

class GridCaptchaDemoPage extends StatefulWidget {
  const GridCaptchaDemoPage({super.key});

  @override
  State<GridCaptchaDemoPage> createState() => _GridCaptchaDemoPageState();
}

class _GridCaptchaDemoPageState extends State<GridCaptchaDemoPage> {
  String _status = 'Click to start verification';
  Color _statusColor = Colors.grey;

  void _showCaptchaDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Verify it's you", style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              GridCaptchaWidget(
                width: 300,
                title: null, // Title handled by dialog
                onSuccess: () {
                  Navigator.pop(context);
                  setState(() {
                    _status = '✓ Verification successful!';
                    _statusColor = Colors.green;
                  });
                },
                onFailed: () {
                  // Widget handles internal state, but we can update page status if needed
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
        title: const Text('Grid Selection CAPTCHA'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(
                _statusColor == Colors.green
                    ? Icons.check_circle
                    : _statusColor == Colors.red
                    ? Icons.error
                    : Icons.grid_view,
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
          ],
        ),
      ),
    );
  }
}
