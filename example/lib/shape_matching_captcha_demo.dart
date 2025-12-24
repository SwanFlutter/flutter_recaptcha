import 'dart:math';

import 'package:flutter/material.dart';

class ShapeMatchingCaptchaDemo extends StatefulWidget {
  const ShapeMatchingCaptchaDemo({super.key});

  @override
  State<ShapeMatchingCaptchaDemo> createState() =>
      _ShapeMatchingCaptchaDemoState();
}

class _ShapeMatchingCaptchaDemoState extends State<ShapeMatchingCaptchaDemo> {
  bool _isVerified = false;
  String _verificationResult = '';

  void _showShapeMatchingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ShapeMatchingDialog(
          onVerified: (success) {
            setState(() {
              _isVerified = success;
              _verificationResult = success
                  ? '✅ Shape matching successful!'
                  : '❌ Incorrect shape selection';
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shape Matching Captcha Demo'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shape Matching Challenge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Click the button below to open the shape matching dialog. You will need to select specific shapes as instructed.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...const [
                      '• Dialog-based interface',
                      '• 9-box grid layout',
                      '• Shape type selection',
                      '• Interactive verification',
                      '• Clear instructions',
                    ].map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
                        child: Text('• $feature'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: _showShapeMatchingDialog,
                icon: const Icon(Icons.category, size: 24),
                label: const Text(
                  'Start Shape Matching',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_verificationResult.isNotEmpty)
              Card(
                color: _isVerified ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isVerified ? Icons.check_circle : Icons.error,
                        color: _isVerified ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _verificationResult,
                          style: TextStyle(
                            color: _isVerified ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How it works:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Click "Start Shape Matching" button\n'
                      '2. Dialog opens with 9 shape boxes\n'
                      '3. Read the instruction at the top\n'
                      '4. Select the required shapes\n'
                      '5. Click Verify to check your answer\n'
                      '6. Dialog closes and shows result',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapeMatchingDialog extends StatefulWidget {
  final Function(bool) onVerified;

  const ShapeMatchingDialog({super.key, required this.onVerified});

  @override
  State<ShapeMatchingDialog> createState() => _ShapeMatchingDialogState();
}

class _ShapeMatchingDialogState extends State<ShapeMatchingDialog> {
  List<ShapeBox> _shapeBoxes = [];
  String _instruction = '';
  int _requiredSelections = 0;
  List<int> _selectedIndices = [];

  @override
  void initState() {
    super.initState();
    _generateShapes();
  }

  void _generateShapes() {
    final random = Random();
    _shapeBoxes = [];
    _selectedIndices = [];

    // Define shape types
    final shapeTypes = [
      ShapeType.circle,
      ShapeType.square,
      ShapeType.rectangle,
      ShapeType.triangle,
      ShapeType.pentagon,
      ShapeType.hexagon,
      ShapeType.star,
      ShapeType.diamond,
      ShapeType.oval,
    ];

    // Shuffle and take 9 shapes
    shapeTypes.shuffle(random);
    final selectedShapes = shapeTypes.take(9).toList();

    // Count circles for instruction
    final circleCount = selectedShapes
        .where((s) => s == ShapeType.circle)
        .length;

    // Create instruction
    if (circleCount > 0) {
      _instruction = 'Select all CIRCLES from the shapes below';
      _requiredSelections = circleCount;
    } else {
      // If no circles, ask for squares
      final squareCount = selectedShapes
          .where((s) => s == ShapeType.square)
          .length;
      _instruction = 'Select all SQUARES from the shapes below';
      _requiredSelections = squareCount;
    }

    // Create shape boxes
    for (int i = 0; i < selectedShapes.length; i++) {
      _shapeBoxes.add(
        ShapeBox(index: i, shapeType: selectedShapes[i], isSelected: false),
      );
    }
  }

  void _toggleShape(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        _shapeBoxes[index].isSelected = false;
      } else {
        _selectedIndices.add(index);
        _shapeBoxes[index].isSelected = true;
      }
    });
  }

  void _verifySelection() {
    // Count selected circles
    int selectedCircles = 0;
    for (final index in _selectedIndices) {
      if (_shapeBoxes[index].shapeType == ShapeType.circle) {
        selectedCircles++;
      }
    }

    // Check if correct number of circles selected
    final totalCircles = _shapeBoxes
        .where((box) => box.shapeType == ShapeType.circle)
        .length;
    final isCorrect =
        selectedCircles == totalCircles &&
        _selectedIndices.length == totalCircles;

    widget.onVerified(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.category, color: Colors.teal, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Shape Matching Challenge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),

              // Instruction
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _instruction,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Shape Grid (3x3)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _shapeBoxes.length,
                itemBuilder: (context, index) {
                  final shapeBox = _shapeBoxes[index];
                  return GestureDetector(
                    onTap: () => _toggleShape(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: shapeBox.isSelected
                            ? Colors.teal.withOpacity(0.2)
                            : Colors.grey.shade50,
                        border: Border.all(
                          color: shapeBox.isSelected
                              ? Colors.teal
                              : Colors.grey.shade300,
                          width: shapeBox.isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(40, 40),
                          painter: SimpleShapePainter(
                            shapeBox.shapeType,
                            shapeBox.isSelected
                                ? Colors.teal
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Selection info
              Text(
                'Selected: ${_selectedIndices.length} shapes',
                style: TextStyle(
                  color: _selectedIndices.length == _requiredSelections
                      ? Colors.green
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndices.clear();
                        for (var box in _shapeBoxes) {
                          box.isSelected = false;
                        }
                      });
                    },
                    child: const Text('Clear'),
                  ),
                  ElevatedButton(
                    onPressed: _verifySelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Verify'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShapeBox {
  final int index;
  final ShapeType shapeType;
  bool isSelected;

  ShapeBox({
    required this.index,
    required this.shapeType,
    this.isSelected = false,
  });
}

enum ShapeType {
  circle,
  square,
  rectangle,
  triangle,
  pentagon,
  hexagon,
  star,
  diamond,
  oval,
}

class SimpleShapePainter extends CustomPainter {
  final ShapeType type;
  final Color color;

  SimpleShapePainter(this.type, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;

    switch (type) {
      case ShapeType.circle:
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeType.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: size.width * 0.8,
            height: size.height * 0.8,
          ),
          paint,
        );
        break;
      case ShapeType.rectangle:
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: size.width * 0.9,
            height: size.height * 0.6,
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
      case ShapeType.pentagon:
        _drawPolygon(canvas, center, radius, 5, paint);
        break;
      case ShapeType.hexagon:
        _drawPolygon(canvas, center, radius, 6, paint);
        break;
      case ShapeType.star:
        _drawStar(canvas, center, radius, paint);
        break;
      case ShapeType.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy)
          ..lineTo(center.dx, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.oval:
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: size.width * 0.8,
            height: size.height * 0.5,
          ),
          paint,
        );
        break;
    }
  }

  void _drawPolygon(
    Canvas canvas,
    Offset center,
    double radius,
    int sides,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * pi) / sides - pi / 2;
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
