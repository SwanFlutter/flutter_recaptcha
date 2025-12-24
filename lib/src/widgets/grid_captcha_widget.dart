import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A grid-based CAPTCHA widget that presents pattern recognition challenges.
/// 
/// This widget displays a 3x3 grid with various challenges including:
/// - Number patterns (even/odd numbers)
/// - Shape patterns (circles, triangles, stars)
/// - Interactive selection with visual feedback
/// - Haptic feedback for user interactions
/// - Automatic validation and reset functionality
/// 
/// Example usage:
/// ```dart
/// GridCaptchaWidget(
///   width: 300,
///   title: 'Security Check',
///   onSuccess: () {
///     print('Pattern verified successfully!');
///   },
///   onFailed: () {
///     print('Pattern verification failed');
///   },
/// )
/// ```
class GridCaptchaWidget extends StatefulWidget {
  /// Width of the widget container
  /// 
  /// Defaults to 300 pixels
  final double width;
  
  /// Callback function called when pattern verification is successful
  /// 
  /// Called after the user correctly selects all required items
  final VoidCallback? onSuccess;
  
  /// Callback function called when pattern verification fails
  /// 
  /// Called when the user makes an incorrect selection
  final VoidCallback? onFailed;
  
  /// Optional title displayed above the challenge
  /// 
  /// Defaults to 'Security Check'
  final String? title;

  const GridCaptchaWidget({
    super.key,
    this.width = 300,
    this.onSuccess,
    this.onFailed,
    this.title,
  });

  @override
  State<GridCaptchaWidget> createState() => _GridCaptchaWidgetState();
}

class _GridCaptchaWidgetState extends State<GridCaptchaWidget> {
  String _status = 'Loading challenge...';
  String _patternChallenge = '';
  List<int> _selectedPattern = [];
  List<int> _correctPattern = [];
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _generatePatternChallenge();
  }

  void _generatePatternChallenge() {
    final challenges = [
      'Select all even numbers',
      'Select all odd numbers',
      'Select all circles',
      'Select all triangles',
      'Select all stars',
    ];

    final random = Random();
    _patternChallenge = challenges[random.nextInt(challenges.length)];
    _selectedPattern = [];
    _correctPattern = [];

    _generateCorrectPattern();
    setState(() {
      _status = _patternChallenge;
    });
  }

  void _generateCorrectPattern() {
    switch (_patternChallenge) {
      case 'Select all even numbers':
        _correctPattern = [1, 3, 5, 7]; // 2, 4, 6, 8 (0-indexed: 1,3,5,7)
        break;
      case 'Select all odd numbers':
        _correctPattern = [0, 2, 4, 6, 8]; // 1, 3, 5, 7, 9
        break;
      case 'Select all circles':
        _correctPattern = [0, 2, 4, 6];
        break;
      case 'Select all triangles':
        _correctPattern = [1, 3, 5, 7];
        break;
      case 'Select all stars':
        _correctPattern = [0, 4, 8];
        break;
    }
  }

  void _handlePatternTap(int index) {
    if (_isVerified) return;

    if (_selectedPattern.contains(index)) {
      _selectedPattern.remove(index);
    } else {
      _selectedPattern.add(index);
    }
    setState(() {});
    _checkPatternCompletion();
  }

  void _checkPatternCompletion() {
    final incorrectSelections = _selectedPattern
        .where((index) => !_correctPattern.contains(index))
        .toList();

    if (incorrectSelections.isNotEmpty) {
      HapticFeedback.vibrate();
      setState(() {
        _status = 'Incorrect selection! Try again.';
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _selectedPattern = [];
          _status = _patternChallenge;
        });
      });
      widget.onFailed?.call();
    } else {
      final allCorrectSelected = _correctPattern.every(
        (index) => _selectedPattern.contains(index),
      );

      if (allCorrectSelected &&
          _selectedPattern.length == _correctPattern.length) {
        HapticFeedback.lightImpact();
        setState(() {
          _isVerified = true;
          _status = 'Verified! ✅';
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          widget.onSuccess?.call();
        });
      }
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
          Text(
            widget.title ?? 'Security Check',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _status,
            style: TextStyle(
              fontSize: 14,
              color: _isVerified
                  ? Colors.green
                  : (_status.startsWith('Incorrect')
                        ? Colors.red
                        : Colors.blue),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final isSelected = _selectedPattern.contains(index);
              final isCorrect = _correctPattern.contains(index);

              // Only show red/green feedback if verified or incorrect tap happened
              // But here we show immediate feedback on tap?
              // The original logic showed red immediately on wrong tap.

              Color borderColor = Colors.blue.shade200;
              Color bgColor = Colors.blue.shade50;

              if (isSelected) {
                borderColor = Colors.blue;
                bgColor = Colors.blue.shade100;
              }

              // In this simple version, we don't reveal correct/incorrect until full verification or error
              // But original code showed red immediately if incorrect.
              if (isSelected && !_correctPattern.contains(index)) {
                borderColor = Colors.red;
                bgColor = Colors.red.shade100;
              } else if (_isVerified && isSelected) {
                borderColor = Colors.green;
                bgColor = Colors.green.shade100;
              }

              return GestureDetector(
                onTap: () => _handlePatternTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Center(child: _getPatternWidget(index)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isVerified ? null : _generatePatternChallenge,
                tooltip: 'New Challenge',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getPatternWidget(int index) {
    // 0-8
    // 1-9 displayed
    switch (_patternChallenge) {
      case 'Select all even numbers':
      case 'Select all odd numbers':
        return Text(
          '${index + 1}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        );
      case 'Select all circles':
        return _getShapeWidget(index, _correctPattern, Icons.circle);
      case 'Select all triangles':
        return _getShapeWidget(index, _correctPattern, Icons.change_history);
      case 'Select all stars':
        return _getShapeWidget(index, _correctPattern, Icons.star);
      default:
        return Text('${index + 1}');
    }
  }

  Widget _getShapeWidget(int index, List<int> shapePositions, IconData icon) {
    if (shapePositions.contains(index)) {
      return Icon(icon, size: 32, color: Colors.blue.shade700);
    } else {
      // Distractor shapes
      return Icon(Icons.crop_square, size: 32, color: Colors.grey.shade400);
    }
  }
}
