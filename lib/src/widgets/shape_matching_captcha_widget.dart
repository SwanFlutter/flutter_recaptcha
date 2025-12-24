import 'dart:math';

import 'package:flutter/material.dart';

/// A shape matching CAPTCHA widget that challenges users to identify and select specific shapes.
///
/// This widget presents a visual pattern recognition challenge where users must:
/// - Identify target shapes displayed at the top
/// - Select matching shapes from a grid of options
/// - Match both shape type and color correctly
///
/// Features include:
/// - Dynamic shape generation with various types (circle, square, triangle, star, hexagon)
/// - Multiple color options for increased complexity
/// - Visual feedback for selection and verification
/// - Target shape display with clear indicators
/// - Error handling with user-friendly messages
/// - Success confirmation with visual feedback
///
/// Example usage:
/// ```dart
/// ShapeMatchingCaptchaWidget(
///   onVerified: (isSuccess) {
///     if (isSuccess) {
///       print('Shape matching completed successfully!');
///     }
///   },
///   title: 'Shape Matching Challenge',
///   primaryColor: Colors.blue,
///   size: 60,
/// )
/// ```
class ShapeMatchingCaptchaWidget extends StatefulWidget {
  /// Callback function called when shape matching is verified
  ///
  /// [isSuccess] - true if all selected shapes match the targets, false otherwise
  final Function(bool) onVerified;

  /// Optional title displayed above the challenge
  ///
  /// Defaults to 'Shape Matching Challenge'
  final String? title;

  /// Primary color for UI elements like selection highlights and buttons
  ///
  /// Defaults to Colors.blue
  final Color? primaryColor;

  /// Size of individual shapes in the grid
  ///
  /// Controls the dimensions of shape rendering
  /// Defaults to 50 pixels
  final double? size;

  const ShapeMatchingCaptchaWidget({
    super.key,
    required this.onVerified,
    this.title,
    this.primaryColor,
    this.size,
  });

  @override
  State<ShapeMatchingCaptchaWidget> createState() =>
      _ShapeMatchingCaptchaWidgetState();
}

class _ShapeMatchingCaptchaWidgetState
    extends State<ShapeMatchingCaptchaWidget> {
  List<ShapeData> _shapes = [];
  List<ShapeData> _targetShapes = [];
  List<int> _selectedIndices = [];
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _generateShapes();
  }

  void _generateShapes() {
    final random = Random();
    final shapeTypes = [
      ShapeType.circle,
      ShapeType.square,
      ShapeType.triangle,
      ShapeType.star,
      ShapeType.hexagon,
    ];
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];

    _shapes = [];
    _targetShapes = [];
    _selectedIndices = [];
    _isVerified = false;

    // Generate target shapes (what user should match)
    for (int i = 0; i < 3; i++) {
      final shapeType = shapeTypes[random.nextInt(shapeTypes.length)];
      final color = colors[random.nextInt(colors.length)];

      _targetShapes.add(
        ShapeData(type: shapeType, color: color, isSelected: false),
      );
    }

    // Generate mixed shapes for selection
    final allPossibleShapes = <ShapeData>[];

    // Add correct shapes
    for (final target in _targetShapes) {
      allPossibleShapes.add(
        ShapeData(type: target.type, color: target.color, isSelected: false),
      );
    }

    // Add distractor shapes
    for (int i = 0; i < 6; i++) {
      final shapeType = shapeTypes[random.nextInt(shapeTypes.length)];
      final color = colors[random.nextInt(colors.length)];

      // Make sure it's not exactly the same as target shapes
      final isDuplicate = _targetShapes.any(
        (target) => target.type == shapeType && target.color == color,
      );

      if (!isDuplicate) {
        allPossibleShapes.add(
          ShapeData(type: shapeType, color: color, isSelected: false),
        );
      }
    }

    // Shuffle and take first 8
    allPossibleShapes.shuffle(random);
    _shapes = allPossibleShapes.take(8).toList();
  }

  void _toggleShape(int index) {
    if (_isVerified) return;

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        _shapes[index].isSelected = false;
      } else {
        _selectedIndices.add(index);
        _shapes[index].isSelected = true;
      }
    });
  }

  void _verifySelection() {
    if (_selectedIndices.length != 3) {
      _showError('Please select exactly 3 shapes');
      return;
    }

    final selectedShapes = _selectedIndices
        .map((index) => _shapes[index])
        .toList();
    int correctCount = 0;

    for (final selected in selectedShapes) {
      if (_targetShapes.any(
        (target) =>
            target.type == selected.type && target.color == selected.color,
      )) {
        correctCount++;
      }
    }

    if (correctCount == 3) {
      setState(() {
        _isVerified = true;
      });
      widget.onVerified(true);
    } else {
      _showError('Incorrect selection. Try again!');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _resetChallenge() {
    _generateShapes();
  }

  Widget _buildShape(ShapeData shape, double size, {bool isTarget = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isTarget
            ? shape.color.withValues(alpha: 0.3)
            : Colors.transparent,
        border: isTarget ? Border.all(color: shape.color, width: 2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.8, size * 0.8),
          painter: ShapePainter(shape.type, shape.color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title ?? 'Shape Matching Challenge',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.primaryColor ?? Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select the shapes that match the target patterns:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Target shapes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  'Target Shapes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _targetShapes.map((shape) {
                    return _buildShape(
                      shape,
                      widget.size ?? 50,
                      isTarget: true,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Selection grid
          const Text(
            'Select matching shapes:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _shapes.length,
            itemBuilder: (context, index) {
              final shape = _shapes[index];
              return GestureDetector(
                onTap: () => _toggleShape(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: shape.isSelected
                        ? (widget.primaryColor ?? Colors.blue).withValues(
                            alpha: 0.2,
                          )
                        : Colors.grey.shade50,
                    border: Border.all(
                      color: shape.isSelected
                          ? (widget.primaryColor ?? Colors.blue)
                          : Colors.grey.shade300,
                      width: shape.isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildShape(shape, widget.size ?? 50),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isVerified ? null : _verifySelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor ?? Colors.blue,
                ),
                child: Text(_isVerified ? 'Verified' : 'Verify Selection'),
              ),
              TextButton.icon(
                onPressed: _resetChallenge,
                icon: const Icon(Icons.refresh),
                label: const Text('New Challenge'),
              ),
            ],
          ),

          if (_isVerified)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Perfect Match! Verification Successful!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ShapeData {
  final ShapeType type;
  final Color color;
  bool isSelected;

  ShapeData({required this.type, required this.color, this.isSelected = false});
}

enum ShapeType { circle, square, triangle, star, hexagon }

class ShapePainter extends CustomPainter {
  final ShapeType type;
  final Color color;

  ShapePainter(this.type, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (type) {
      case ShapeType.circle:
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeType.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: size.width,
            height: size.height,
          ),
          paint,
        );
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx - radius, center.dy + radius)
          ..lineTo(center.dx + radius, center.dy + radius)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.star:
        _drawStar(canvas, center, radius, paint);
        break;
      case ShapeType.hexagon:
        _drawHexagon(canvas, center, radius, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const pointCount = 5;
    const outerRadius = 1.0;
    const innerRadius = 0.5;

    for (int i = 0; i < pointCount * 2; i++) {
      final angle = (i * pi) / pointCount - pi / 2;
      final r = i.isEven ? radius * outerRadius : radius * innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi) / 3;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
