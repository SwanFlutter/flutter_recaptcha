import 'dart:math';

import 'package:flutter/material.dart';

/// A number triangle CAPTCHA widget that challenges users to find patterns in triangular number arrangements.
///
/// This widget presents a 4-row number triangle where users must:
/// - Identify the mathematical pattern between numbers
/// - Calculate the sum of all numbers in the bottom row
/// - Understand the relationship between adjacent rows
///
/// Features include:
/// - Dynamic triangle generation with mathematical patterns
/// - Visual highlighting of the target bottom row
/// - Hint system to guide users
/// - Input validation with error feedback
/// - Success confirmation with visual feedback
///
/// Example usage:
/// ```dart
/// NumberTriangleCaptchaWidget(
///   onVerified: (isSuccess) {
///     if (isSuccess) {
///       print('Number triangle solved correctly!');
///     }
///   },
///   title: 'Number Triangle Challenge',
///   primaryColor: Colors.blue,
///   size: 120,
/// )
/// ```
class NumberTriangleCaptchaWidget extends StatefulWidget {
  /// Callback function called when the answer is verified
  ///
  /// [isSuccess] - true if the answer is correct, false otherwise
  final Function(bool) onVerified;

  /// Optional title displayed above the triangle challenge
  ///
  /// Defaults to 'Number Triangle Challenge'
  final String? title;

  /// Primary color for UI elements like buttons and accents
  ///
  /// Defaults to Colors.blue
  final Color? primaryColor;

  /// Size parameter for the widget (currently not used in layout)
  ///
  /// Reserved for future customizations
  final double? size;

  const NumberTriangleCaptchaWidget({
    super.key,
    required this.onVerified,
    this.title,
    this.primaryColor,
    this.size,
  });

  @override
  State<NumberTriangleCaptchaWidget> createState() =>
      _NumberTriangleCaptchaWidgetState();
}

class _NumberTriangleCaptchaWidgetState
    extends State<NumberTriangleCaptchaWidget> {
  late List<List<int>> _triangle;
  late int _correctAnswer;
  final TextEditingController _answerController = TextEditingController();
  bool _isVerified = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _generateTriangle();
  }

  void _generateTriangle() {
    final random = Random();
    _triangle = [];

    // Generate a number triangle with pattern
    for (int row = 0; row < 4; row++) {
      List<int> currentRow = [];
      for (int col = 0; col <= row; col++) {
        if (row == 0) {
          currentRow.add(random.nextInt(9) + 1);
        } else {
          // Each number is sum of two numbers above it
          if (col == 0) {
            currentRow.add(_triangle[row - 1][0] + random.nextInt(3) - 1);
          } else if (col == row) {
            currentRow.add(_triangle[row - 1][row - 1] + random.nextInt(3) - 1);
          } else {
            currentRow.add(
              _triangle[row - 1][col - 1] +
                  _triangle[row - 1][col] +
                  random.nextInt(3) -
                  1,
            );
          }
        }
      }
      _triangle.add(currentRow);
    }

    // Calculate the correct answer (sum of bottom row)
    _correctAnswer = _triangle[3].reduce((a, b) => a + b);
  }

  void _verifyAnswer() {
    final userAnswer = int.tryParse(_answerController.text);
    if (userAnswer != null && userAnswer == _correctAnswer) {
      setState(() {
        _isVerified = true;
      });
      widget.onVerified(true);
    } else {
      _showError();
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Incorrect answer. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _refreshChallenge() {
    setState(() {
      _isVerified = false;
      _showHint = false;
      _answerController.clear();
    });
    _generateTriangle();
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
            widget.title ?? 'Number Triangle Challenge',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.primaryColor ?? Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Find the sum of all numbers in the bottom row:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildTriangle(),
          const SizedBox(height: 20),
          if (_showHint)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Hint: Look for the pattern in the triangle',
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _answerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Your Answer',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isVerified,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isVerified ? null : _verifyAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor ?? Colors.blue,
                ),
                child: const Text('Verify'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _isVerified
                    ? null
                    : () => setState(() => _showHint = !_showHint),
                child: Text(_showHint ? 'Hide Hint' : 'Show Hint'),
              ),
              TextButton.icon(
                onPressed: _refreshChallenge,
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
                    'Verification Successful!',
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

  Widget _buildTriangle() {
    return Column(
      children: List.generate(_triangle.length, (rowIndex) {
        final row = _triangle[rowIndex];
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(row.length * 2 - 1, (index) {
              if (index.isEven) {
                final numberIndex = index ~/ 2;
                return Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: rowIndex == 3
                        ? Colors.orange.shade100
                        : Colors.blue.shade50,
                    border: Border.all(
                      color: rowIndex == 3 ? Colors.orange : Colors.blue,
                      width: rowIndex == 3 ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${row[numberIndex]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: rowIndex == 3
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: rowIndex == 3
                            ? Colors.orange.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox(width: 8);
              }
            }),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
