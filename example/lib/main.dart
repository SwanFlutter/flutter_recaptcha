import 'package:flutter/material.dart';
import 'package:flutter_recaptcha_example/rotation_captcha_demo.dart';
import 'package:flutter_recaptcha_example/text_captcha_demo.dart';
import 'package:flutter_recaptcha_example/slider_captcha_demo.dart';
import 'package:flutter_recaptcha_example/number_triangle_captcha_demo.dart';
import 'package:flutter_recaptcha_example/fingerprint_captcha_demo.dart';
import 'package:flutter_recaptcha_example/math_puzzle_captcha_demo.dart';
import 'package:flutter_recaptcha_example/shape_matching_captcha_demo.dart';
import 'package:flutter_recaptcha_example/all_captchas_demo.dart';
// import 'package:flutter_recaptcha_example/smart_demo_page.dart'; // Commented out as it might be missing

void main() {
  runApp(const RecaptchaApp());
}

class RecaptchaApp extends StatelessWidget {
  const RecaptchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter reCAPTCHA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter reCAPTCHA Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Choose a CAPTCHA Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              
              /* 
              _DemoCard(
                title: 'Smart reCAPTCHA',
                description: 'Intelligent verification with multiple methods',
                icon: Icons.psychology,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const SmartDemoPage(),
                  //   ),
                  // );
                },
              ),
              const SizedBox(height: 16),
              */

              _DemoCard(
                title: 'Rotation CAPTCHA',
                description: 'Rotate the image to match the pattern',
                icon: Icons.rotate_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RotationCaptchaDemoPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _DemoCard(
                title: 'Slider Puzzle CAPTCHA',
                description: 'Drag the puzzle piece to the hole',
                icon: Icons.extension,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SliderCaptchaDemoPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _DemoCard(
                title: 'Text CAPTCHA',
                description: 'Type the characters you see',
                icon: Icons.text_fields,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TextCaptchaDemoPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _DemoCard(
                title: 'Number Triangle CAPTCHA',
                description: 'Solve the number triangle pattern',
                icon: Icons.change_history,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NumberTriangleCaptchaDemo(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _DemoCard(
                title: 'Fingerprint CAPTCHA',
                description: 'Biometric verification simulation',
                icon: Icons.fingerprint,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FingerprintCaptchaDemo(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _DemoCard(
                title: 'Math Puzzle CAPTCHA',
                description: 'Solve mathematical challenges',
                icon: Icons.calculate,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MathPuzzleCaptchaDemo(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _DemoCard(
                title: 'Shape Matching CAPTCHA',
                description: 'Match shapes and colors',
                icon: Icons.category,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShapeMatchingCaptchaDemo(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _DemoCard(
                title: 'All CAPTCHAs Demo',
                description: 'Complete all security challenges',
                icon: Icons.security,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllCaptchasDemo(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _DemoCard(
                title: 'Random Challenge',
                description: 'Random captcha selection',
                icon: Icons.shuffle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RandomCaptchaChallenge(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _DemoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: Colors.blue),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
