import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ویجت CAPTCHA چرخشی - یک تصویر واحد که قسمت داخلی آن چرخیده است
/// کاربر باید با چرخاندن قسمت داخلی، آن را با قسمت بیرونی تطابق دهد
class RotationCaptchaWidget extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onFailed;
  final String? imagePath;
  final double tolerance;
  final Duration animationDuration;

  const RotationCaptchaWidget({
    super.key,
    this.onSuccess,
    this.onFailed,
    this.imagePath,
    this.tolerance = 15.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<RotationCaptchaWidget> createState() => _RotationCaptchaWidgetState();
}

class _RotationCaptchaWidgetState extends State<RotationCaptchaWidget>
    with SingleTickerProviderStateMixin {
  double _currentRotation = 0; // چرخش فعلی قسمت داخلی
  double _initialRotation = 0; // چرخش اولیه تصادفی
  double _sliderValue = 0;
  bool _isVerifying = false;
  bool? _verificationResult;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _generateChallenge();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateChallenge() {
    setState(() {
      // تولید یک زاویه تصادفی برای چرخش اولیه (بین 30 تا 330 درجه)
      _initialRotation = 30 + math.Random().nextDouble() * 300;
      _currentRotation = _initialRotation;
      _sliderValue = 0;
      _verificationResult = null;
    });
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
      // چرخش از زاویه اولیه به سمت 0 (حالت صحیح)
      _currentRotation = _initialRotation * (1 - value);
    });

    // Auto-verify when slider reaches the end
    if (value > 0.95) {
      _verify();
    }
  }

  Future<void> _verify() async {
    setState(() {
      _isVerifying = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // بررسی اینکه آیا تصویر به حالت صحیح (0 درجه) برگشته است
    final difference = _currentRotation.abs();
    final isSuccess = difference <= widget.tolerance;

    setState(() {
      _verificationResult = isSuccess;
      _isVerifying = false;
    });

    if (isSuccess) {
      // تنظیم دقیق به 0 درجه
      setState(() {
        _currentRotation = 0;
      });
      _animationController.forward().then((_) {
        widget.onSuccess?.call();
      });
    } else {
      widget.onFailed?.call();
      await Future.delayed(const Duration(seconds: 1));
      _generateChallenge();
    }
  }

  void _refresh() {
    _generateChallenge();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Drag the slider to fit the puzzle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildRotationPuzzle(),
          const SizedBox(height: 32),
          _buildSlider(),
          const SizedBox(height: 24),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildRotationPuzzle() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // دایره بیرونی (ثابت) - نمایش تصویر کامل
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              border: Border.all(color: Colors.grey[400]!, width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                widget.imagePath ?? 'assets/dog_outer.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          // دایره داخلی (قابل چرخش) - نمایش قسمت مرکزی تصویر که چرخیده است
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _currentRotation * math.pi / 180,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _verificationResult == null
                          ? Colors.white
                          : _verificationResult!
                          ? Colors.green
                          : Colors.red,
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.imagePath ?? 'assets/dog_outer.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          // نشانگر موفقیت
          if (_verificationResult == true)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Progress indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: _sliderValue * MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 0,
              thumbShape: _CustomThumbShape(),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: _isVerifying ? null : _onSliderChanged,
              activeColor: Colors.transparent,
              inactiveColor: Colors.transparent,
            ),
          ),
          // Hint text
          if (_sliderValue < 0.1)
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Drag the slider to fit the puzzle',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _isVerifying ? null : _refresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
        if (_verificationResult == false)
          const Text('Try again', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(56, 56);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw shadow
    canvas.drawCircle(
      center,
      28,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Draw thumb background
    canvas.drawCircle(center, 26, Paint()..color = Colors.white);

    // Draw border
    canvas.drawCircle(
      center,
      26,
      Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw arrow icon
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '→',
        style: TextStyle(fontSize: 24, color: Colors.grey),
      ),
      textDirection: textDirection,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );
  }
}
