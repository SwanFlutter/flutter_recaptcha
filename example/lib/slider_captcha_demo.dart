import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

class SliderCaptchaDemoPage extends StatefulWidget {
  const SliderCaptchaDemoPage({super.key});

  @override
  State<SliderCaptchaDemoPage> createState() => _SliderCaptchaDemoPageState();
}

class _SliderCaptchaDemoPageState extends State<SliderCaptchaDemoPage> {
  String _status = 'Click to start verification';
  Color _statusColor = Colors.grey;

  void _showSliderCaptcha() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Slide to Verify",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              SliderCaptchaWidget(
                imageProvider: const AssetImage('assets/dog_outer.jpg'),
                width: 280,
                height: 180,
                sliderWidth: 280,
                onSuccess: () {
                  Navigator.pop(context);
                  setState(() {
                    _status = '✓ Verification successful!';
                    _statusColor = Colors.green;
                  });
                },
                onFailed: () {
                  // Optional: update local status or vibrate
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
        title: const Text('Slider Puzzle Demo'),
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
                    : Icons.extension,
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
                onPressed: _showSliderCaptcha,
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

              const SizedBox(height: 48),
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
                      Text('1. A puzzle piece is cut from the image'),
                      Text('2. Drag the slider to move the piece'),
                      Text('3. Align the piece with the hole'),
                      Text('4. Release to verify'),
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
