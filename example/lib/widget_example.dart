import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

/// Example showing how to use the built-in reCAPTCHA widgets
class WidgetExample extends StatefulWidget {
  const WidgetExample({super.key});

  @override
  State<WidgetExample> createState() => _WidgetExampleState();
}

class _WidgetExampleState extends State<WidgetExample> {
  final _formKey = GlobalKey<FormState>();
  String _message = '';

  final _config = const RecaptchaConfig(
    siteKey: 'your-site-key-here',
    type: RecaptchaType.smart,
    enableBiometric: true,
    enableBehavioralAnalysis: true,
    enableDeviceFingerprinting: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('reCAPTCHA Widgets Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_message.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(_message),
                ),
              ),
            const SizedBox(height: 20),
            
            // Example 1: Simple RecaptchaWidget
            const Text(
              '1. Basic RecaptchaWidget:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RecaptchaWidget(
              config: _config,
              action: 'widget_test',
              onResult: (result) {
                setState(() {
                  _message = result.success
                      ? 'Widget verification successful! Score: ${result.score?.toStringAsFixed(2)}'
                      : 'Widget verification failed: ${result.errorMessage}';
                });
              },
              onError: (error) {
                setState(() {
                  _message = 'Widget error: $error';
                });
              },
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            
            // Example 2: RecaptchaButton
            const Text(
              '2. RecaptchaButton (auto-verify on press):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RecaptchaButton(
              config: _config,
              action: 'button_test',
              onPressed: () {
                setState(() {
                  _message = 'Button action executed after successful verification!';
                });
              },
              onVerified: (result) {
                setState(() {
                  _message = 'Button verification successful! Score: ${result.score?.toStringAsFixed(2)}';
                });
              },
              onError: (error) {
                setState(() {
                  _message = 'Button error: $error';
                });
              },
              child: const Text('Verify & Execute Action'),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            
            // Example 3: Form with RecaptchaFormField
            const Text(
              '3. Form with RecaptchaFormField:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  RecaptchaFormField(
                    config: _config,
                    action: 'form_submit',
                    onVerified: (result) {
                      setState(() {
                        _message = 'Form reCAPTCHA verified! Score: ${result.score?.toStringAsFixed(2)}';
                      });
                    },
                    onError: (error) {
                      setState(() {
                        _message = 'Form reCAPTCHA error: $error';
                      });
                    },
                    validator: (value) {
                      if (value != true) {
                        return 'Please complete reCAPTCHA verification';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _message = 'Form submitted successfully!';
                        });
                      }
                    },
                    child: const Text('Submit Form'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            
            // Example 4: Custom widget with manual control
            const Text(
              '4. Custom implementation:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RecaptchaWidget(
              config: _config,
              action: 'custom_test',
              autoInitialize: false,
              child: Column(
                children: [
                  const Text('Custom reCAPTCHA implementation'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final recaptcha = FlutterRecaptcha.instance;
                          final success = await recaptcha.initialize(_config);
                          setState(() {
                            _message = success 
                                ? 'Custom initialization successful!'
                                : 'Custom initialization failed!';
                          });
                        },
                        child: const Text('Initialize'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final recaptcha = FlutterRecaptcha.instance;
                          if (!recaptcha.isInitialized) {
                            setState(() {
                              _message = 'Please initialize first!';
                            });
                            return;
                          }
                          
                          final result = await recaptcha.verify(action: 'custom_verify');
                          setState(() {
                            _message = result.success
                                ? 'Custom verification successful! Score: ${result.score?.toStringAsFixed(2)}'
                                : 'Custom verification failed: ${result.errorMessage}';
                          });
                        },
                        child: const Text('Verify'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
