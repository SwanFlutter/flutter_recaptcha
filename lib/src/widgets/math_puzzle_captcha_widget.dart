import 'dart:math';

import 'package:flutter/material.dart';

import '../tools/challenge_difficulty.dart';

/// A mathematical puzzle CAPTCHA widget that challenges users with arithmetic problems.
///
/// This widget provides mathematical challenges with varying difficulty levels:
/// - Easy: Simple arithmetic (+, -, ×) with small numbers
/// - Medium: Multi-step equations with order of operations
/// - Hard: Square roots, percentages, and complex equations
/// - Adaptive: Adjusts to user skill level
///
/// Features include:
/// - Dynamic question generation based on difficulty
/// - Hint system to assist users
/// - Visual difficulty indicator
/// - Input validation with error feedback
/// - Success confirmation with visual feedback
///
/// Example usage:
/// ```dart
/// MathPuzzleCaptchaWidget(
///   onVerified: (isSuccess) {
///     if (isSuccess) {
///       print('Math puzzle solved correctly!');
///     }
///   },
///   title: 'Solve the Equation',
///   difficulty: ChallengeDifficulty.medium,
///   primaryColor: Colors.blue,
/// )
/// ```
class MathPuzzleCaptchaWidget extends StatefulWidget {
  /// Callback function called when the answer is verified
  ///
  /// [isSuccess] - true if the answer is correct, false otherwise
  final Function(bool) onVerified;

  /// Optional title displayed above the math challenge
  ///
  /// Defaults to 'Math Puzzle Challenge'
  final String? title;

  /// Primary color for UI elements like buttons and accents
  ///
  /// Defaults to Colors.blue
  final Color? primaryColor;

  /// Difficulty level for the math challenges
  ///
  /// Affects the complexity of generated equations
  /// Defaults to ChallengeDifficulty.medium
  final ChallengeDifficulty difficulty;

  const MathPuzzleCaptchaWidget({
    super.key,
    required this.onVerified,
    this.title,
    this.primaryColor,
    this.difficulty = ChallengeDifficulty.medium,
  });

  @override
  State<MathPuzzleCaptchaWidget> createState() =>
      _MathPuzzleCaptchaWidgetState();
}

class _MathPuzzleCaptchaWidgetState extends State<MathPuzzleCaptchaWidget> {
  late String _question;
  late int _correctAnswer;
  final TextEditingController _answerController = TextEditingController();
  bool _isVerified = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();

    switch (widget.difficulty) {
      case ChallengeDifficulty.easy:
        _generateEasyQuestion(random);
        break;
      case ChallengeDifficulty.medium:
        _generateMediumQuestion(random);
        break;
      case ChallengeDifficulty.hard:
        _generateHardQuestion(random);
        break;
      case ChallengeDifficulty.adaptive:
        // Default to medium for adaptive difficulty
        _generateMediumQuestion(random);
        break;
    }
  }

  void _generateEasyQuestion(Random random) {
    final a = random.nextInt(20) + 1;
    final b = random.nextInt(20) + 1;
    final operations = ['+', '-', '×'];
    final operation = operations[random.nextInt(operations.length)];

    switch (operation) {
      case '+':
        _question = '$a + $b = ?';
        _correctAnswer = a + b;
        break;
      case '-':
        _question = '$a - $b = ?';
        _correctAnswer = a - b;
        break;
      case '×':
        _question = '$a × $b = ?';
        _correctAnswer = a * b;
        break;
    }
  }

  void _generateMediumQuestion(Random random) {
    final a = random.nextInt(50) + 10;
    final b = random.nextInt(20) + 5;
    final c = random.nextInt(10) + 1;

    final operations = ['+', '-', '×'];
    final op1 = operations[random.nextInt(operations.length)];
    final op2 = operations[random.nextInt(operations.length)];

    _question = '$a $op1 $b $op2 $c = ?';

    switch (op1) {
      case '+':
        switch (op2) {
          case '+':
            _correctAnswer = a + b + c;
            break;
          case '-':
            _correctAnswer = a + b - c;
            break;
          case '×':
            _correctAnswer = a + (b * c);
            break;
        }
        break;
      case '-':
        switch (op2) {
          case '+':
            _correctAnswer = a - b + c;
            break;
          case '-':
            _correctAnswer = a - b - c;
            break;
          case '×':
            _correctAnswer = a - (b * c);
            break;
        }
        break;
      case '×':
        switch (op2) {
          case '+':
            _correctAnswer = (a * b) + c;
            break;
          case '-':
            _correctAnswer = (a * b) - c;
            break;
          case '×':
            _correctAnswer = a * b * c;
            break;
        }
        break;
    }
  }

  void _generateHardQuestion(Random random) {
    final type = random.nextInt(3);

    switch (type) {
      case 0: // Square root
        final a = random.nextInt(20) + 4;
        _question = '√$a² = ?';
        _correctAnswer = a;
        break;
      case 1: // Percentage
        final a = random.nextInt(100) + 10;
        final b = random.nextInt(50) + 10;
        _correctAnswer = ((a * b) / 100).round();
        _question = '$b% of $a = ?';
        break;
      case 2: // Complex equation
        final x = random.nextInt(10) + 1;
        final a = random.nextInt(10) + 1;
        final b = random.nextInt(20) + 5;
        _correctAnswer = x;
        _question = '$x × $a + $b = ${x * a + b - b} + ?';
        break;
    }
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
    _generateQuestion();
  }

  String _getHint() {
    switch (widget.difficulty) {
      case ChallengeDifficulty.easy:
        return 'Try using basic arithmetic operations';
      case ChallengeDifficulty.medium:
        return 'Remember the order of operations (PEMDAS)';
      case ChallengeDifficulty.hard:
        return 'Think about mathematical formulas and properties';
      case ChallengeDifficulty.adaptive:
        return 'This challenge adapts to your skill level';
    }
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
          Row(
            children: [
              Text(
                widget.title ?? 'Math Puzzle Challenge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryColor ?? Colors.blue,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.difficulty.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Solve the following equation:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _question,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          if (_showHint)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getHint(),
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
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
                    'Correct! Verification Successful!',
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

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
      case ChallengeDifficulty.adaptive:
        return Colors.purple;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
