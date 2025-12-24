import 'dart:math';
import 'package:flutter/material.dart';

class TextCaptchaWidget extends StatefulWidget {
  final double width;
  final double height;
  final int length;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailed;
  final TextStyle? codeStyle;
  final InputDecoration? inputDecoration;

  const TextCaptchaWidget({
    super.key,
    this.width = 300,
    this.height = 200,
    this.length = 5,
    this.onSuccess,
    this.onFailed,
    this.codeStyle,
    this.inputDecoration,
  });

  @override
  State<TextCaptchaWidget> createState() => _TextCaptchaWidgetState();
}

class _TextCaptchaWidgetState extends State<TextCaptchaWidget> {
  late String _captchaCode;
  final TextEditingController _controller = TextEditingController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No I, O, 1, 0
    _captchaCode = List.generate(
      widget.length,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
    _controller.clear();
    setState(() {});
  }

  void _verify() {
    if (_controller.text.toUpperCase() == _captchaCode) {
      widget.onSuccess?.call();
    } else {
      widget.onFailed?.call();
      _controller.clear();
      _generateCaptcha(); // Regenerate on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Captcha Display
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                // Noise lines
                ...List.generate(10, (index) {
                  return Positioned(
                    left: _random.nextDouble() * (widget.width - 50),
                    top: _random.nextDouble() * 60,
                    child: Container(
                      width: _random.nextDouble() * 50 + 20,
                      height: 2,
                      color: Colors.grey.withOpacity(0.3),
                      transform: Matrix4.rotationZ(_random.nextDouble() * pi),
                    ),
                  );
                }),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _captchaCode.split('').map((char) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.rotate(
                          angle: (_random.nextDouble() - 0.5) * 0.5,
                          child: Text(
                            char,
                            style: widget.codeStyle ??
                                const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                  letterSpacing: 4,
                                ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Input and Buttons
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: widget.inputDecoration ??
                      const InputDecoration(
                        hintText: 'Enter code',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                  onSubmitted: (_) => _verify(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _generateCaptcha,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Code',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Verify'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
