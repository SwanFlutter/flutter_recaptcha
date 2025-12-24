// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A modern interactive rotation CAPTCHA widget with circular image alignment.
///
/// This widget presents a visual puzzle where users must:
/// - Rotate an inner circle to align with the outer circle
/// - Use a horizontal slider to control rotation (0-360 degrees)
/// - Match the image patterns between inner and outer sections
///
/// Features include:
/// - Custom image support with fallback to default assets
/// - Smooth rotation animations with visual feedback
/// - Draggable slider with progress indication
/// - Success/failure animations and visual indicators
/// - Configurable tolerance for alignment validation
/// - Refresh functionality for new challenges
///
/// Example usage:
/// ```dart
/// RotationCaptchaWidget(
///   imagePath: 'assets/your_image.jpg',
///   width: 300,
///   height: 300,
///   tolerance: 15.0,
///   onSuccess: () {
///     print('Rotation puzzle solved successfully!');
///   },
///   onFailed: () {
///     print('Rotation puzzle failed');
///   },
/// )
/// ```
class RotationCaptchaWidget extends StatefulWidget {
  /// The image provider for the captcha (preferred over imagePath)
  ///
  /// If provided, takes precedence over imagePath
  final ImageProvider? imageProvider;

  /// Asset path for the image (backward compatibility)
  ///
  /// Falls back to 'assets/dog_outer.jpg' if not specified
  final String? imagePath;

  /// Width of the captcha widget
  ///
  /// Defaults to 240 pixels
  final double width;

  /// Height of the captcha widget
  ///
  /// Defaults to 240 pixels
  final double height;

  /// Width of the slider control
  ///
  /// If null, defaults to the widget width
  final double? sliderWidth;

  /// Ratio of inner circle radius to outer circle radius (0.0 to 1.0)
  ///
  /// Controls the size of the rotatable inner section
  /// Defaults to 0.66 (approximately 2/3)
  final double innerRadiusRatio;

  /// Callback function called when validation succeeds
  ///
  /// Called when the inner circle is aligned within tolerance
  final VoidCallback? onSuccess;

  /// Callback function called when validation fails
  ///
  /// Called when alignment is outside the tolerance range
  final VoidCallback? onFailed;

  /// Acceptable error margin in degrees for alignment
  ///
  /// Smaller values require more precise alignment
  /// Defaults to 10.0 degrees
  final double tolerance;

  /// Duration for success animations
  ///
  /// Controls the timing of the success confirmation animation
  final Duration animationDuration;

  const RotationCaptchaWidget({
    super.key,
    this.imageProvider,
    this.imagePath,
    this.width = 240, // Match snippet default
    this.height = 240, // Match snippet default
    this.sliderWidth,
    this.innerRadiusRatio = 0.66, // 160/240 ~= 0.66
    this.onSuccess,
    this.onFailed,
    this.tolerance = 10.0,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<RotationCaptchaWidget> createState() => _RotationCaptchaWidgetState();
}

class _RotationCaptchaWidgetState extends State<RotationCaptchaWidget>
    with SingleTickerProviderStateMixin {
  double _sliderValue = 0.0;
  double _initialRotation = 0.0; // The random starting offset
  double _currentRotation = 0.0; // Effective rotation applied to inner circle

  bool _isVerifying = false;
  bool? _isSuccess;

  ui.Image? _image;
  bool _isLoading = true;

  late AnimationController _successController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeOutBack,
    );

    _loadImage();
    _generateChallenge();
  }

  @override
  void didUpdateWidget(RotationCaptchaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider ||
        widget.imagePath != oldWidget.imagePath) {
      _loadImage();
    }
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);

    try {
      final ImageProvider provider =
          widget.imageProvider ??
          (widget.imagePath != null
              ? AssetImage(widget.imagePath!)
              : const AssetImage('assets/dog_outer.jpg'));

      final ImageStream stream = provider.resolve(ImageConfiguration.empty);
      final Completer<ui.Image> completer = Completer();

      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo frame, bool synchronousCall) {
          completer.complete(frame.image);
          stream.removeListener(listener);
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          completer.completeError(exception);
          stream.removeListener(listener);
        },
      );

      stream.addListener(listener);
      final loadedImage = await completer.future;

      if (mounted) {
        setState(() {
          _image = loadedImage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading image: $e');
    }
  }

  void _generateChallenge() {
    setState(() {
      // Random rotation between 30 and 330 degrees to ensure it's not already aligned
      final random = math.Random();
      final angle = 30 + random.nextDouble() * 300;
      // Randomly decide direction (positive or negative)
      _initialRotation = random.nextBool() ? angle : -angle;

      _sliderValue = 0.0;
      _currentRotation = _initialRotation;
      _isSuccess = null;
      _isVerifying = false;
      _successController.reset();
    });
  }

  void _onSliderChanged(double value) {
    if (_isSuccess == true || _isVerifying) return;

    setState(() {
      _sliderValue = value;
      // Map slider 0.0 to 1.0 to a rotation of 0 to 360 degrees.
      // This guarantees that the user can always find the correct alignment.
      _currentRotation = _initialRotation + (value * 360);
    });
  }

  Future<void> _verify() async {
    if (_isSuccess == true || _isVerifying) return;

    // Only verify if slider is dragged significantly (optional, but matching snippet logic helps)
    if (_sliderValue < 0.05) return;

    setState(() => _isVerifying = true);

    // Normalize angle to -180..180
    double angle = _currentRotation % 360;
    if (angle > 180) angle -= 360;
    if (angle < -180) angle += 360;

    // Check if close to 0
    final bool valid = angle.abs() < widget.tolerance;

    if (valid) {
      setState(() {
        _isSuccess = true;
        _isVerifying = false;
        // Snap to perfect 0 visually
        _currentRotation -= angle;
      });
      _successController.forward();
      widget.onSuccess?.call();
    } else {
      setState(() {
        _isSuccess = false;
        _isVerifying = false;
      });
      widget.onFailed?.call();

      // Reset after delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isSuccess = null; // Clear error state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _image == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final double outerRadius = math.min(widget.width, widget.height) / 2;
    final double innerRadius = outerRadius * widget.innerRadiusRatio;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Puzzle Area
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom Painter for Outer and Inner circles
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _CaptchaPainter(
                    image: _image!,
                    outerRadius: outerRadius,
                    innerRadius: innerRadius,
                    rotationAngle: _currentRotation * math.pi / 180,
                    isSuccess: _isSuccess,
                    successAnimation: _scaleAnimation,
                  ),
                ),
              ),
              // Success Icon Overlay
              if (_isSuccess == true)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                ),
              if (_isSuccess == false)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 40),
                ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Custom Slider Control
        _buildCustomSlider(),

        const SizedBox(height: 24),

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _generateChallenge,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomSlider() {
    return Container(
      width: widget.sliderWidth ?? widget.width,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          // Calculate thumb position based on slider value
          // Thumb width is 60, so travel distance is maxWidth - 60
          final double travelDistance = maxWidth - 60;
          final double thumbLeft = _sliderValue * travelDistance;

          return Stack(
            children: [
              // Progress Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: thumbLeft + 60, // Include thumb width in filled part
                height: 50,
                decoration: BoxDecoration(
                  color: _isSuccess == true
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),

              // Hint Text
              if (_sliderValue < 0.1 && _isSuccess != true)
                Center(
                  child: Text(
                    'Drag the slider to fit the puzzle',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),

              // Draggable Thumb
              Positioned(
                left: thumbLeft,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isSuccess == true || _isVerifying) return;

                    // Calculate new value
                    // delta.dx is pixel change
                    // Change in value = delta.dx / travelDistance
                    double newValue =
                        _sliderValue + (details.delta.dx / travelDistance);
                    newValue = newValue.clamp(0.0, 1.0);
                    _onSliderChanged(newValue);
                  },
                  onHorizontalDragEnd: (details) {
                    _verify();
                  },
                  child: Container(
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isSuccess == true
                          ? Colors.green.shade400
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: _isSuccess == true
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CaptchaPainter extends CustomPainter {
  final ui.Image image;
  final double outerRadius;
  final double innerRadius;
  final double rotationAngle;
  final bool? isSuccess;
  final Animation<double> successAnimation;

  _CaptchaPainter({
    required this.image,
    required this.outerRadius,
    required this.innerRadius,
    required this.rotationAngle,
    this.isSuccess,
    required this.successAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final Paint paint = Paint()..isAntiAlias = true;

    // Calculate scaling to cover the circle with the image
    final double scale = math.max(
      (outerRadius * 2) / image.width,
      (outerRadius * 2) / image.height,
    );

    final double scaledWidth = image.width * scale;
    final double scaledHeight = image.height * scale;

    // Matrix to center and scale the image
    final Matrix4 matrix = Matrix4.identity()
      ..translate(center.dx - scaledWidth / 2, center.dy - scaledHeight / 2)
      ..scale(scale);

    // 1. Draw Outer Circle (Full image, darkened)
    final Path outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius));

    canvas.save();
    canvas.clipPath(outerPath);

    // Draw normal image first
    _drawImageCentered(canvas, center, scale);

    // Draw dark overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..blendMode = BlendMode.darken,
    );

    canvas.restore();

    // 2. Draw Inner Circle (Full image, rotated, bright)
    final Path innerCirclePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius));

    canvas.save();

    // Rotate around center
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Shadow for inner circle
    // We draw shadow before clipping
    canvas.drawShadow(
      innerCirclePath,
      Colors.black.withValues(alpha: 0.5),
      10.0,
      true,
    );

    // Clip to inner circle
    canvas.clipPath(innerCirclePath);

    // Draw the same image (bright)
    _drawImageCentered(canvas, center, scale);

    canvas.restore();

    // Draw border/overlay for inner circle
    final Color borderColor = isSuccess == true
        ? Colors.green
        : (isSuccess == false ? Colors.red : Colors.white);

    canvas.drawPath(
      innerCirclePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = borderColor
        ..strokeWidth = 3.0,
    );
  }

  void _drawImageCentered(Canvas canvas, Offset center, double scale) {
    final double width = image.width.toDouble();
    final double height = image.height.toDouble();

    final Rect src = Rect.fromLTWH(0, 0, width, height);
    final Rect dst = Rect.fromCenter(
      center: center,
      width: width * scale,
      height: height * scale,
    );

    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant _CaptchaPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.image != image ||
        oldDelegate.isSuccess != isSuccess;
  }
}
