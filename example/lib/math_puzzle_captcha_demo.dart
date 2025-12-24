import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';
import 'package:flutter_recaptcha/flutter_recaptcha_platform_interface.dart';

class MathPuzzleCaptchaDemo extends StatefulWidget {
  const MathPuzzleCaptchaDemo({Key? key}) : super(key: key);

  @override
  State<MathPuzzleCaptchaDemo> createState() => _MathPuzzleCaptchaDemoState();
}

class _MathPuzzleCaptchaDemoState extends State<MathPuzzleCaptchaDemo> {
  bool _isVerified = false;
  String _verificationResult = '';
  ChallengeDifficulty _selectedDifficulty = ChallengeDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Puzzle Captcha Demo'),
        backgroundColor: Colors.orange,
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
                      'Math Puzzle Challenge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This captcha presents mathematical problems of varying difficulty that users must solve to prove they are human.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...const [
                      '• Multiple difficulty levels',
                      '• Dynamic question generation',
                      '• Arithmetic to complex equations',
                      '• Hint system for guidance',
                      '• Visual difficulty indicators',
                    ].map((feature) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 2),
                      child: Text('• $feature'),
                    )),
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
                      'Select Difficulty:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ChallengeDifficulty.values.map((difficulty) {
                        final isSelected = _selectedDifficulty == difficulty;
                        return FilterChip(
                          label: Text(difficulty.name.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDifficulty = difficulty;
                              _isVerified = false;
                              _verificationResult = '';
                            });
                          },
                          backgroundColor: _getDifficultyColor(difficulty).withOpacity(0.2),
                          selectedColor: _getDifficultyColor(difficulty),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : _getDifficultyColor(difficulty),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            MathPuzzleCaptchaWidget(
              title: 'Solve the Math Problem',
              primaryColor: Colors.orange,
              difficulty: _selectedDifficulty,
              onVerified: (success) {
                setState(() {
                  _isVerified = success;
                  _verificationResult = success
                      ? '✅ Math puzzle solved successfully!'
                      : '❌ Incorrect answer, try again';
                });
              },
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
                        _isVerified ? Icons.calculate : Icons.error,
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
                      'Difficulty Levels:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildDifficultyInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDifficultyItem('Easy', 'Basic arithmetic: +, -, ×', Colors.green),
        const SizedBox(height: 4),
        _buildDifficultyItem('Medium', 'Multi-step equations with order of operations', Colors.orange),
        const SizedBox(height: 4),
        _buildDifficultyItem('Hard', 'Complex problems: square roots, percentages, algebra', Colors.red),
      ],
    );
  }

  Widget _buildDifficultyItem(String level, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4, right: 8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              '$level: $description',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
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
}
