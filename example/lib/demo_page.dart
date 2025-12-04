import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';
import 'package:flutter_recaptcha_example/simple_example.dart';
import 'package:flutter_recaptcha_example/widget_example.dart';

/// صفحه نمایش ویژگی‌های reCAPTCHA مدرن
class RecaptchaDemoPage extends StatefulWidget {
  const RecaptchaDemoPage({super.key});

  @override
  State<RecaptchaDemoPage> createState() => _RecaptchaDemoPageState();
}

class _RecaptchaDemoPageState extends State<RecaptchaDemoPage> {
  final _recaptcha = FlutterRecaptcha.instance;
  String _status = 'آماده برای شروع';
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('reCAPTCHA مدرن'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // نمایش وضعیت
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'وضعیت:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: _isInitialized ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isInitialized ? 'راه‌اندازی شده' : 'راه‌اندازی نشده',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // دکمه راه‌اندازی
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _initializeRecaptcha,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.settings),
              label: const Text('راه‌اندازی reCAPTCHA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            // دکمه تأیید هوشمند
            ElevatedButton.icon(
              onPressed:
                  (_isInitialized && !_isLoading) ? _smartVerification : null,
              icon: const Icon(Icons.psychology),
              label: const Text('تأیید هوشمند'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            // دکمه تأیید بیومتریک
            ElevatedButton.icon(
              onPressed:
                  (_isInitialized && !_isLoading)
                      ? _biometricVerification
                      : null,
              icon: const Icon(Icons.fingerprint),
              label: const Text('تأیید با اثر انگشت'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            // دکمه اثر انگشت دستگاه
            ElevatedButton.icon(
              onPressed:
                  (_isInitialized && !_isLoading) ? _getDeviceInfo : null,
              icon: const Icon(Icons.devices),
              label: const Text('اطلاعات دستگاه'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 20),

            // توضیحات ویژگی‌ها
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ویژگی‌های مدرن:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(child: Text('تأیید هوشمند و تطبیقی')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.fingerprint, color: Colors.purple),
                        SizedBox(width: 8),
                        Expanded(child: Text('احراز هویت بیومتریک')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(child: Text('تجزیه و تحلیل رفتاری')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.security, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(child: Text('شناسایی دستگاه')),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WidgetExample(),
                          ),
                        );
                      },
                      child: const Text("ssss"),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const SimpleRecaptchaExample(),
                          ),
                        );
                      },
                      child: const Text("www"),
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

  Future<void> _initializeRecaptcha() async {
    setState(() {
      _isLoading = true;
      _status = 'در حال راه‌اندازی...';
    });

    try {
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
        _status = success ? 'راه‌اندازی موفق!' : 'خطا در راه‌اندازی';
      });
    } catch (e) {
      setState(() {
        _status = 'خطا: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _smartVerification() async {
    setState(() {
      _isLoading = true;
      _status = 'در حال تأیید هوشمند...';
    });

    try {
      final result = await _recaptcha.verify(action: 'smart_demo');

      setState(() {
        _status =
            result.success
                ? 'تأیید موفق! امتیاز: ${(result.score! * 100).toInt()}%'
                : 'تأیید ناموفق: ${result.errorMessage}';
      });

      if (result.success) {
        _showSuccessDialog('تأیید هوشمند', result);
      }
    } catch (e) {
      setState(() {
        _status = 'خطا در تأیید: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _biometricVerification() async {
    setState(() {
      _isLoading = true;
      _status = 'بررسی دسترسی بیومتریک...';
    });

    try {
      final isAvailable = await _recaptcha.isBiometricAvailable();

      if (!isAvailable) {
        setState(() {
          _status = 'احراز هویت بیومتریک در دسترس نیست';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _status = 'در حال احراز هویت بیومتریک...';
      });

      final result = await _recaptcha.verify(action: 'biometric_demo');

      setState(() {
        _status =
            result.success
                ? 'احراز هویت بیومتریک موفق!'
                : 'احراز هویت ناموفق: ${result.errorMessage}';
      });

      if (result.success) {
        _showSuccessDialog('احراز هویت بیومتریک', result);
      }
    } catch (e) {
      setState(() {
        _status = 'خطا در احراز هویت: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getDeviceInfo() async {
    setState(() {
      _isLoading = true;
      _status = 'در حال دریافت اطلاعات دستگاه...';
    });

    try {
      final fingerprint = await _recaptcha.getDeviceFingerprint();

      setState(() {
        _status = 'اثر انگشت دستگاه: ${fingerprint.substring(0, 16)}...';
      });

      _showInfoDialog('اطلاعات دستگاه', 'اثر انگشت دستگاه:\n$fingerprint');
    } catch (e) {
      setState(() {
        _status = 'خطا در دریافت اطلاعات: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String title, RecaptchaResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('وضعیت: ${result.success ? "موفق" : "ناموفق"}'),
                if (result.score != null)
                  Text('امتیاز: ${(result.score! * 100).toInt()}%'),
                if (result.challengeType != null)
                  Text('نوع: ${result.challengeType}'),
                if (result.token != null)
                  Text('توکن: ${result.token!.substring(0, 20)}...'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('باشه'),
              ),
            ],
          ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SelectableText(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('باشه'),
              ),
            ],
          ),
    );
  }
}
