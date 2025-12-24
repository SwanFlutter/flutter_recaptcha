// ignore_for_file: unused_local_variable

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A slider-based puzzle CAPTCHA widget with jigsaw piece verification.
///
/// This widget presents an interactive sliding puzzle where users must:
/// - Drag a puzzle piece horizontally to match the target position
/// - Align the piece with the corresponding "hole" in the background
/// - Complete the verification within a specified tolerance range
///
/// Features include:
/// - Custom image support with automatic scaling
/// - Realistic jigsaw piece shape with bumps and indentations
/// - Smooth sliding animations with visual feedback
/// - Success/failure states with color-coded indicators
/// - Configurable tolerance for validation precision
/// - Automatic reset on failed attempts
///
/// Example usage:
/// ```dart
/// SliderCaptchaWidget(
///   imageProvider: AssetImage('assets/puzzle_image.jpg'),
///   width: 300,
///   height: 150,
///   tolerance: 0.05,
///   onSuccess: () {
///     print('Slider puzzle solved successfully!');
///   },
///   onFailed: () {
///     print('Slider puzzle failed');
///   },
/// )
/// ```
class SliderCaptchaWidget extends StatefulWidget {
  /// The image provider for the puzzle background
  ///
  /// Required - used as both background and puzzle piece source
  final ImageProvider imageProvider;

  /// Width of the puzzle area
  ///
  /// Defaults to 300 pixels
  final double width;

  /// Height of the puzzle area
  ///
  /// Defaults to 150 pixels
  final double height;

  /// Width of the slider control
  ///
  /// Can be different from puzzle area width
  /// Defaults to 300 pixels
  final double sliderWidth;

  /// Callback function called when puzzle is solved successfully
  ///
  /// Called when the piece aligns within tolerance
  final VoidCallback? onSuccess;

  /// Callback function called when puzzle verification fails
  ///
  /// Called when alignment is outside tolerance range
  final VoidCallback? onFailed;

  /// Acceptable error tolerance for alignment (0.0 to 1.0)
  ///
  /// Smaller values require more precise positioning
  /// Defaults to 0.05 (5% tolerance)
  final double tolerance;

  const SliderCaptchaWidget({
    super.key,
    required this.imageProvider,
    this.width = 300,
    this.height = 150,
    this.sliderWidth = 300,
    this.onSuccess,
    this.onFailed,
    this.tolerance = 0.05, // 5% tolerance
  });

  @override
  State<SliderCaptchaWidget> createState() => _SliderCaptchaWidgetState();
}

class _SliderCaptchaWidgetState extends State<SliderCaptchaWidget> {
  double _sliderValue = 0.0;
  double _puzzlePosition = 0.0; // 0.0 to 1.0 (relative to width)
  double _targetPosition = 0.0; // 0.0 to 1.0
  ui.Image? _image;
  bool _isSuccess = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _resetPuzzle();
  }

  void _loadImage() {
    final ImageStream stream = widget.imageProvider.resolve(
      ImageConfiguration.empty,
    );
    stream.addListener(
      ImageStreamListener((info, _) {
        if (mounted) {
          setState(() {
            _image = info.image;
            _isLoading = false;
          });
        }
      }),
    );
  }

  void _resetPuzzle() {
    setState(() {
      // Random target position between 0.5 and 0.9 (right half)
      _targetPosition = 0.5 + (math.Random().nextDouble() * 0.4);
      _sliderValue = 0.0;
      _puzzlePosition = 0.0;
      _isSuccess = false;
    });
  }

  void _onSliderChanged(double value) {
    if (_isSuccess) return;
    setState(() {
      _sliderValue = value;
      // Map slider 0-1 to puzzle position 0-1 (but capped at max width)
      _puzzlePosition = value;
    });
  }

  void _onSliderEnd(double value) {
    if (_isSuccess) return;

    // Check if within tolerance
    if ((_puzzlePosition - _targetPosition).abs() < widget.tolerance) {
      setState(() {
        _isSuccess = true;
        _puzzlePosition = _targetPosition; // Snap to perfect
      });
      widget.onSuccess?.call();
    } else {
      widget.onFailed?.call();
      // Animate back to start or just stay? Usually snap back
      setState(() {
        _sliderValue = 0.0;
        _puzzlePosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _image == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height + 60,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _PuzzlePainter(
              image: _image!,
              puzzlePosition: _puzzlePosition,
              targetPosition: _targetPosition,
              isSuccess: _isSuccess,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: widget.sliderWidth,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track text
              Center(
                child: Text(
                  _isSuccess ? "Verified!" : "Slide to verify",
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Slider Thumb
              Positioned(
                left: _sliderValue * (widget.sliderWidth - 50),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    double newValue =
                        (_sliderValue +
                                details.delta.dx / (widget.sliderWidth - 50))
                            .clamp(0.0, 1.0);
                    _onSliderChanged(newValue);
                  },
                  onHorizontalDragEnd: (details) => _onSliderEnd(_sliderValue),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isSuccess ? Colors.green : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isSuccess ? Icons.check : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PuzzlePainter extends CustomPainter {
  final ui.Image image;
  final double puzzlePosition;
  final double targetPosition;
  final bool isSuccess;

  _PuzzlePainter({
    required this.image,
    required this.puzzlePosition,
    required this.targetPosition,
    required this.isSuccess,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final pieceSize = size.height * 0.3; // Size of the puzzle piece
    final double yPos =
        size.height *
        0.35; // Y position of the piece (centered vertically mostly)

    // Calculate scaling to cover
    final double scaleX = size.width / image.width;
    final double scaleY = size.height / image.height;
    final double scale = math.max(scaleX, scaleY);

    // Draw background image
    final Rect src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final Rect dst = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Draw full dimmed background image
    canvas.drawImageRect(image, src, dst, paint);
    canvas.drawRect(dst, Paint()..color = Colors.black.withValues(alpha: 0.3));

    // Create puzzle path
    final path = _getPuzzlePath(pieceSize);

    // 2. Draw the "hole" at target position
    final double targetX = targetPosition * (size.width - pieceSize);

    canvas.save();
    canvas.translate(targetX, yPos);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // 3. Draw the moving puzzle piece
    final double currentX = puzzlePosition * (size.width - pieceSize);

    canvas.save();
    canvas.translate(currentX, yPos);

    // Clip to puzzle shape
    canvas.clipPath(path);

    // Draw the segment of the image corresponding to the TARGET position (because that's what we want to match)
    // We need to draw the image such that when this piece is at targetX, it matches the background.
    // So we translate the image backwards by targetX.
    canvas.translate(
      -targetX,
      -yPos,
    ); // Move back to origin relative to the hole's position in image
    canvas.drawImageRect(image, src, dst, Paint()); // Draw full image (clipped)

    // Draw border/highlight
    canvas.translate(targetX, yPos); // Restore context to draw border on top
    canvas.drawPath(
      path,
      Paint()
        ..color = isSuccess ? Colors.green : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    canvas.restore();
  }

  Path _getPuzzlePath(double size) {
    final path = Path();
    final double bumpSize = size / 4;

    path.moveTo(0, 0);
    // Top bump
    path.lineTo(size / 2 - bumpSize / 2, 0);
    path.cubicTo(
      size / 2 - bumpSize,
      -bumpSize,
      size / 2 + bumpSize,
      -bumpSize,
      size / 2 + bumpSize / 2,
      0,
    );
    path.lineTo(size, 0);

    // Right bump
    path.lineTo(size, size / 2 - bumpSize / 2);
    path.cubicTo(
      size + bumpSize,
      size / 2 - bumpSize,
      size + bumpSize,
      size / 2 + bumpSize,
      size,
      size / 2 + bumpSize / 2,
    );
    path.lineTo(size, size);

    // Bottom
    path.lineTo(0, size);

    // Left bump (inward)
    path.lineTo(0, size / 2 + bumpSize / 2);
    path.cubicTo(
      bumpSize,
      size / 2 + bumpSize,
      bumpSize,
      size / 2 - bumpSize,
      0,
      size / 2 - bumpSize / 2,
    );
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
