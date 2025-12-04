import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

/// ویجت reCAPTCHA هوشمند و جذاب
class SmartRecaptchaWidget extends StatefulWidget {
  final VoidCallback? onVerified;
  final Function(String)? onError;

  const SmartRecaptchaWidget({super.key, this.onVerified, this.onError});

  @override
  State<SmartRecaptchaWidget> createState() => _SmartRecaptchaWidgetState();
}

class _SmartRecaptchaWidgetState extends State<SmartRecaptchaWidget>
    with TickerProviderStateMixin {
  final _recaptcha = FlutterRecaptcha.instance;

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isVerified = false;
  bool _showChallenge = false;
  String _challengeType = '';
  String _status = '';
  String _patternChallenge = '';
  List<int> _selectedPattern = []; // حذف final
  List<int> _correctPattern = [];

  late AnimationController _pulseController;
  late AnimationController _checkController;
  late AnimationController _challengeController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _challengeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeRecaptcha();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _challengeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _challengeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _challengeController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeRecaptcha() async {
    final config = RecaptchaConfig(
      siteKey: 'demo-site-key',
      type: RecaptchaType.smart,
      enableBiometric: true,
      enableBehavioralAnalysis: true,
      enableDeviceFingerprinting: true,
    );

    final success = await _recaptcha.initialize(config);
    setState(() {
      _isInitialized = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عنوان
          const Text(
            'تأیید هویت هوشمند',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // چک باکس اصلی
          _buildMainCheckbox(),

          const SizedBox(height: 15),

          // نمایش وضعیت
          if (_status.isNotEmpty)
            Text(
              _status,
              style: TextStyle(
                fontSize: 14,
                color: _isVerified ? Colors.green : Colors.blue,
              ),
            ),

          // نمایش چالش
          if (_showChallenge) ...[
            const SizedBox(height: 20),
            _buildChallenge(),
          ],
        ],
      ),
    );
  }

  Widget _buildMainCheckbox() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleMainClick,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isLoading ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCheckboxColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getBorderColor(), width: 2),
              ),
              child: _buildCheckboxContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckboxContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
      );
    }

    if (_isVerified) {
      return AnimatedBuilder(
        animation: _checkAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _checkAnimation.value,
            child: const Icon(Icons.check, color: Colors.white, size: 30),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Color _getCheckboxColor() {
    if (_isVerified) return Colors.green;
    if (_isLoading) return Colors.blue;
    return Colors.grey.shade200;
  }

  Color _getBorderColor() {
    if (_isVerified) return Colors.green;
    if (_isLoading) return Colors.blue;
    return Colors.grey.shade400;
  }

  Widget _buildChallenge() {
    return AnimatedBuilder(
      animation: _challengeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _challengeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: _getChallengeWidget(),
          ),
        );
      },
    );
  }

  Widget _getChallengeWidget() {
    switch (_challengeType) {
      case 'biometric':
        return _buildBiometricChallenge();
      case 'behavioral':
        return _buildBehavioralChallenge();
      case 'pattern':
        return _buildPatternChallenge();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBiometricChallenge() {
    return Column(
      children: [
        const Icon(Icons.fingerprint, size: 50, color: Colors.purple),
        const SizedBox(height: 10),
        const Text(
          'لطفاً اثر انگشت خود را اسکن کنید',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          onPressed: _performBiometricAuth,
          icon: const Icon(Icons.fingerprint),
          label: const Text('اسکن اثر انگشت'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBehavioralChallenge() {
    return Column(
      children: [
        const Icon(Icons.psychology, size: 50, color: Colors.orange),
        const SizedBox(height: 10),
        const Text('لطفاً ۵ ثانیه صبر کنید...', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 15),
        LinearProgressIndicator(
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ],
    );
  }

  Widget _buildPatternChallenge() {
    return Column(
      children: [
        Icon(_getChallengeIcon(), size: 40, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          _patternChallenge,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _buildPatternGrid(),
      ],
    );
  }

  Widget _buildPatternGrid() {
    return GridView.builder(
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

        return GestureDetector(
          onTap: () => _handlePatternTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isCorrect ? Colors.green.shade100 : Colors.red.shade100)
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Colors.blue.shade300,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Center(child: _getPatternWidget(index)),
                if (isSelected && isCorrect)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                if (isSelected && !isCorrect)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.cancel, color: Colors.red, size: 16),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getPatternWidget(int index) {
    switch (_patternChallenge) {
      case 'اعداد زوج را کلیک کنید':
      case 'اعداد فرد را کلیک کنید':
        return Text(
          '${index + 1}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        );
      case 'روی دایره‌ها کلیک کنید':
        return _getShapeWidget(index, _correctPattern, Icons.circle);
      case 'روی مثلث‌ها کلیک کنید':
        return _getShapeWidget(index, _correctPattern, Icons.change_history);
      case 'روی ستاره‌ها کلیک کنید':
        return _getShapeWidget(index, _correctPattern, Icons.star);
      default:
        return Text('${index + 1}');
    }
  }

  Widget _getShapeWidget(int index, List<int> shapePositions, IconData icon) {
    if (shapePositions.contains(index)) {
      return Icon(icon, size: 24, color: Colors.blue.shade700);
    } else {
      return Icon(Icons.crop_square, size: 24, color: Colors.grey.shade400);
    }
  }

  Future<void> _handleMainClick() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
      _status = 'در حال تجزیه و تحلیل...';
    });

    await Future.delayed(const Duration(seconds: 2));
    final challengeType = await _decideChallengeType();

    setState(() {
      _challengeType = challengeType;
      _isLoading = false;
    });

    if (challengeType == 'none') {
      _completeVerification();
    } else {
      setState(() {
        _showChallenge = true;
        _status = 'لطفاً چالش را تکمیل کنید';
      });
      _challengeController.forward();

      if (challengeType == 'behavioral') {
        _performBehavioralChallenge();
      } else if (challengeType == 'pattern') {
        _generatePatternChallenge();
      }
    }
  }

  IconData _getChallengeIcon() {
    switch (_patternChallenge) {
      case 'اعداد زوج را کلیک کنید':
        return Icons.filter_2;
      case 'اعداد فرد را کلیک کنید':
        return Icons.filter_1;
      case 'روی دایره‌ها کلیک کنید':
        return Icons.circle;
      case 'روی مثلث‌ها کلیک کنید':
        return Icons.change_history;
      case 'روی ستاره‌ها کلیک کنید':
        return Icons.star;
      default:
        return Icons.touch_app;
    }
  }

  void _generatePatternChallenge() {
    final challenges = [
      'اعداد زوج را کلیک کنید',
      'اعداد فرد را کلیک کنید',
      'روی دایره‌ها کلیک کنید',
      'روی مثلث‌ها کلیک کنید',
      'روی ستاره‌ها کلیک کنید',
    ];

    final random = Random();
    _patternChallenge = challenges[random.nextInt(challenges.length)];
    _selectedPattern = []; // ریست کامل
    _correctPattern = [];

    _generateCorrectPattern();
    setState(() {});
  }

  void _generateCorrectPattern() {
    switch (_patternChallenge) {
      case 'اعداد زوج را کلیک کنید':
        _correctPattern = [1, 3, 5, 7]; // 2, 4, 6, 8
        break;
      case 'اعداد فرد را کلیک کنید':
        _correctPattern = [0, 2, 4, 6, 8]; // 1, 3, 5, 7, 9
        break;
      case 'روی دایره‌ها کلیک کنید':
        _correctPattern = [0, 2, 4, 6];
        break;
      case 'روی مثلث‌ها کلیک کنید':
        _correctPattern = [1, 3, 5, 7];
        break;
      case 'روی ستاره‌ها کلیک کنید':
        _correctPattern = [0, 4, 8];
        break;
    }
  }

  Future<String> _decideChallengeType() async {
    final random = Random();
    final risk = random.nextDouble();

    if (risk < 0.3) return 'none';
    if (risk < 0.6) return 'behavioral';

    final isBiometricAvailable = await _recaptcha.isBiometricAvailable();
    if (risk < 0.8 && isBiometricAvailable) {
      return 'biometric';
    }

    return 'pattern';
  }

  void _handlePatternTap(int index) {
    if (_selectedPattern.contains(index)) {
      _selectedPattern.remove(index);
    } else {
      _selectedPattern.add(index);
    }
    setState(() {});
    _checkPatternCompletion();
  }

  void _checkPatternCompletion() {
    final correctSelections = _selectedPattern
        .where((index) => _correctPattern.contains(index))
        .toList();
    final incorrectSelections = _selectedPattern
        .where((index) => !_correctPattern.contains(index))
        .toList();

    if (incorrectSelections.isNotEmpty) {
      HapticFeedback.vibrate();
      setState(() {
        _status = 'انتخاب اشتباه! دوباره تلاش کنید';
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _selectedPattern = [];
          _status = 'لطفاً چالش را تکمیل کنید';
        });
      });
    } else {
      final allCorrectSelected = _correctPattern.every(
        (index) => _selectedPattern.contains(index),
      );

      if (allCorrectSelected &&
          _selectedPattern.length == _correctPattern.length) {
        HapticFeedback.lightImpact();
        setState(() {
          _status = 'عالی! الگو صحیح تشخیص داده شد';
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          _completeVerification();
        });
      } else {
        setState(() {
          _status =
              '${correctSelections.length}/${_correctPattern.length} انتخاب شده';
        });
      }
    }
  }

  Future<void> _performBehavioralChallenge() async {
    await _recaptcha.startBehavioralAnalysis();
    await Future.delayed(const Duration(seconds: 5));
    final result = await _recaptcha.stopBehavioralAnalysis();

    if (result.success) {
      _completeVerification();
    } else {
      _showError('تجزیه و تحلیل رفتاری ناموفق بود');
    }
  }

  Future<void> _performBiometricAuth() async {
    setState(() {
      _status = 'در حال احراز هویت بیومتریک...';
    });

    try {
      final result = await _recaptcha.verify(action: 'biometric');
      if (result.success) {
        _completeVerification();
      } else {
        _showError('احراز هویت ناموفق بود');
      }
    } catch (e) {
      _showError('خطا در احراز هویت: $e');
    }
  }

  void _completeVerification() {
    HapticFeedback.lightImpact();

    setState(() {
      _isVerified = true;
      _showChallenge = false;
      _status = 'تأیید موفق! ✅';
    });

    _pulseController.stop();
    _checkController.forward();
    _challengeController.reverse();

    widget.onVerified?.call();
  }

  void _showError(String message) {
    setState(() {
      _status = message;
      _isLoading = false;
      _showChallenge = false;
    });

    widget.onError?.call(message);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    _challengeController.dispose();
    super.dispose();
  }
}
