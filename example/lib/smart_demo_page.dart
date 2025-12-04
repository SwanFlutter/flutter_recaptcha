import 'package:flutter/material.dart';

import 'smart_recaptcha_widget.dart';

/// صفحه نمایش reCAPTCHA هوشمند
class SmartDemoPage extends StatefulWidget {
  const SmartDemoPage({super.key});

  @override
  State<SmartDemoPage> createState() => _SmartDemoPageState();
}

class _SmartDemoPageState extends State<SmartDemoPage> {
  bool _isFormValid = false;
  bool _isRecaptchaVerified = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('reCAPTCHA هوشمند'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // توضیحات
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'منطق reCAPTCHA هوشمند',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '۱. روی چک‌باکس کلیک کنید\n'
                    '۲. سیستم رفتار شما را تجزیه و تحلیل می‌کند\n'
                    '۳. بر اساس سطح ریسک، چالش مناسب انتخاب می‌شود:\n'
                    '   • ریسک پایین: تأیید فوری ✅\n'
                    '   • ریسک متوسط: تجزیه رفتاری 🧠\n'
                    '   • ریسک بالا: اثر انگشت 👆 (فقط موبایل)\n'
                    '   • ریسک خیلی بالا: چالش‌های هوشمند:\n'
                    '     - اعداد زوج/فرد کلیک کنید\n'
                    '     - روی دایره‌ها کلیک کنید\n'
                    '     - روی مثلث‌ها کلیک کنید\n'
                    '     - روی ستاره‌ها کلیک کنید',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // فرم ورود
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                onChanged: _validateForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'ورود به حساب کاربری',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // فیلد ایمیل
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'ایمیل',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً ایمیل خود را وارد کنید';
                        }
                        if (!value.contains('@')) {
                          return 'ایمیل معتبر وارد کنید';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // فیلد رمز عبور
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'رمز عبور',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً رمز عبور خود را وارد کنید';
                        }
                        if (value.length < 6) {
                          return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // reCAPTCHA هوشمند
                    Center(
                      child: SmartRecaptchaWidget(
                        onVerified: () {
                          setState(() {
                            _isRecaptchaVerified = true;
                          });
                          _showSuccessMessage('reCAPTCHA تأیید شد! ✅');
                        },
                        onError: (error) {
                          setState(() {
                            _isRecaptchaVerified = false;
                          });
                          _showErrorMessage(error);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // دکمه ورود
                    ElevatedButton(
                      onPressed:
                          (_isFormValid && _isRecaptchaVerified)
                              ? _handleLogin
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'ورود',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // نمایش وضعیت
                    if (!_isFormValid || !_isRecaptchaVerified)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getStatusMessage(),
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // راهنمای استفاده
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'نکات مهم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• هر بار کلیک، نوع چالش متفاوت خواهد بود\n'
                    '• اثر انگشت فقط در موبایل (Android/iOS) کار می‌کند\n'
                    '• چالش‌های الگو شامل اعداد، اشکال مختلف\n'
                    '• انتخاب اشتباه باعث ریست چالش می‌شود\n'
                    '• سیستم رفتار شما را یاد می‌گیرد\n'
                    '• امنیت بالا با تجربه کاربری عالی',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  String _getStatusMessage() {
    if (!_isFormValid && !_isRecaptchaVerified) {
      return 'لطفاً فرم را تکمیل کرده و reCAPTCHA را تأیید کنید';
    } else if (!_isFormValid) {
      return 'لطفاً فرم را به درستی تکمیل کنید';
    } else if (!_isRecaptchaVerified) {
      return 'لطفاً reCAPTCHA را تأیید کنید';
    }
    return '';
  }

  void _handleLogin() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('ورود موفق'),
              ],
            ),
            content: const Text(
              'شما با موفقیت وارد شدید!\n'
              'reCAPTCHA هوشمند هویت شما را تأیید کرد.',
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
