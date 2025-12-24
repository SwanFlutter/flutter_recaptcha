import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha_platform_interface.dart';

/// A fingerprint authentication CAPTCHA widget that simulates biometric verification.
///
/// This widget provides an interactive fingerprint scanning interface with:
/// - Animated fingerprint scanner with pulsing effect
/// - Progress indicator during scanning
/// - Visual feedback for success/failure states
/// - Customizable colors and sizes
/// - 70% simulated success rate for demo purposes
///
/// Example usage:
/// ```dart
/// FingerprintCaptchaWidget(
///   onVerified: (isSuccess) {
///     if (isSuccess) {
///       print('Fingerprint verified successfully!');
///     }
///   },
///   title: 'Verify Your Identity',
///   primaryColor: Colors.blue,
///   size: 120,
/// )
/// ```
class FingerprintCaptchaWidget extends StatefulWidget {
  /// Callback function when fingerprint verification is completed
  ///
  /// [isSuccess] - true if verification was successful, false otherwise
  final Function(bool) onVerified;

  /// Optional title displayed above the fingerprint scanner
  ///
  /// Defaults to 'Fingerprint Verification'
  final String? title;

  /// Primary color for the widget UI elements
  ///
  /// Used for scanner border, progress indicator, and buttons
  /// Defaults to Colors.blue
  final Color? primaryColor;

  /// Size of the fingerprint scanner circle
  ///
  /// Both width and height will be set to this value
  /// Defaults to 120
  final double? size;

  const FingerprintCaptchaWidget({
    super.key,
    required this.onVerified,
    this.title,
    this.primaryColor,
    this.size,
  });

  @override
  State<FingerprintCaptchaWidget> createState() =>
      _FingerprintCaptchaWidgetState();
}

class _FingerprintCaptchaWidgetState extends State<FingerprintCaptchaWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

  bool _isScanning = false;
  bool _isVerified = false;
  double _scanProgress = 0.0;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scanController, curve: Curves.linear));

    _animationController.repeat(reverse: true);
  }

  void _startFingerprintScan() async {
    if (_isScanning || _isVerified) return;

    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
    });

    _scanController.repeat();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _scanProgress += 0.03;
        if (_scanProgress >= 1.0) {
          _scanProgress = 1.0;
          timer.cancel();
          _completeScan();
        }
      });
    });
  }

  void _completeScan() async {
    _scanController.stop();
    _scanController.reset();

    try {
      final isAvailable = await FlutterRecaptchaPlatform.instance.isBiometricAvailable();
      
      if (!isAvailable) {
        setState(() {
          _isScanning = false;
        });
        _showError('Biometric authentication not available on this device');
        return;
      }

      final result = await FlutterRecaptchaPlatform.instance.authenticateWithBiometric();
      final isSuccess = result.success;

      setState(() {
        _isScanning = false;
        _isVerified = isSuccess;
      });

      if (isSuccess) {
        widget.onVerified(true);
      } else {
        final errorMessage = result.errorMessage ?? 'Fingerprint verification failed';
        _showError(errorMessage);
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showError('Error during biometric authentication: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _reset() {
    setState(() {
      _isVerified = false;
      _isScanning = false;
      _scanProgress = 0.0;
    });
    _scanController.reset();
    _scanTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title ?? 'Fingerprint Verification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.primaryColor ?? Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          _buildFingerprintScanner(),
          const SizedBox(height: 20),
          if (_isScanning)
            Column(
              children: [
                LinearProgressIndicator(
                  value: _scanProgress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.primaryColor ?? Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scanning fingerprint... ${(_scanProgress * 100).toInt()}%',
                  style: TextStyle(
                    color: widget.primaryColor ?? Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: (_isScanning || _isVerified)
                    ? null
                    : _startFingerprintScan,
                icon: _isScanning
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor ?? Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
          if (_isVerified)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Fingerprint Verified Successfully!',
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

  Widget _buildFingerprintScanner() {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _scanAnimation]),
      builder: (context, child) {
        return Container(
          width: widget.size ?? 120,
          height: widget.size ?? 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _isScanning
                  ? (widget.primaryColor ?? Colors.blue).withValues(alpha: 0.8)
                  : Colors.grey.shade300,
              width: _isScanning ? 3 : 2,
            ),
            boxShadow: _isScanning
                ? [
                    BoxShadow(
                      color: (widget.primaryColor ?? Colors.blue).withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 20 * _pulseAnimation.value,
                      spreadRadius: 5 * _pulseAnimation.value,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Fingerprint icon
              Center(
                child: Icon(
                  Icons.fingerprint,
                  size: (widget.size ?? 120) * 0.5,
                  color: _isVerified
                      ? Colors.green
                      : _isScanning
                      ? (widget.primaryColor ?? Colors.blue).withValues(
                          alpha: 0.8,
                        )
                      : Colors.grey.shade400,
                ),
              ),
              // Scanning line effect
              if (_isScanning)
                Positioned.fill(
                  child: ClipOval(
                    child: Align(
                      alignment: Alignment(0, -1 + _scanAnimation.value * 2),
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              (widget.primaryColor ?? Colors.blue).withValues(
                                alpha: 0.8,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Success checkmark
              if (_isVerified)
                const Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }
}
