# Flutter reCAPTCHA

A comprehensive Flutter plugin for implementing various types of CAPTCHA verification including:
- Smart reCAPTCHA with adaptive challenge selection
- Biometric Authentication (Fingerprint/Face ID)
- Behavioral Analysis
- **Rotation CAPTCHA** - New! ✨
- Pattern Recognition Challenges

[![pub package](https://img.shields.io/badge/pub-v0.0.2-blue)](https://pub.dev/packages/flutter_recaptcha)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

### 1. Smart reCAPTCHA
- Automatic challenge type selection based on risk assessment
- Combines multiple authentication methods
- Device fingerprinting
- User behavioral analysis
- Pattern recognition challenges (numbers, shapes)

### 2. Rotation CAPTCHA (New!)
- Display a single image with rotated inner section
- User must rotate the inner part to match the outer part
- Similar to popular CAPTCHA systems like reCAPTCHA
- Beautiful and user-friendly interface
- Customizable tolerance and animation

### 3. Biometric Authentication
- Fingerprint and Face ID support
- Seamless integration with device biometric systems
- Platform-specific implementation (Android/iOS)

### 4. Behavioral Analysis
- Analyzes user interaction patterns
- Distinguishes human behavior from bots
- Non-intrusive verification

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_recaptcha:
    git:
      url: https://github.com/SwanFlutter/flutter_recaptcha
```

Or if published to pub.dev:

```yaml
dependencies:
  flutter_recaptcha: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android Setup

#### 1. Update `android/build.gradle`

The biometric dependency is already included in the plugin, but ensure your app's minimum SDK version is set correctly:

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 24  // Required for biometric
        targetSdkVersion 34
    }
}
```

#### 2. Add Permissions

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Biometric Permission -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />
    
    <!-- Internet Permission (if using online verification) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Optional: For device fingerprinting -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
</manifest>
```

### iOS Setup

#### 1. Update `ios/Podfile`

Ensure your iOS deployment target is at least 12.0:

```ruby
platform :ios, '12.0'
```

#### 2. Add Privacy Descriptions

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>We need to verify your identity using Face ID</string>

<key>NSBiometricUsageDescription</key>
<string>We need to verify your identity using biometric authentication</string>
```

## Usage

### 1. Basic Initialization

```dart
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

final recaptcha = FlutterRecaptcha.instance;

// Initialize with configuration
await recaptcha.initialize(
  RecaptchaConfig(
    siteKey: 'YOUR_SITE_KEY',
    type: RecaptchaType.smart,
    enableBiometric: true,
    enableBehavioralAnalysis: true,
    enableDeviceFingerprinting: true,
  ),
);
```

### 2. Simple Verification

```dart
// Perform verification
final result = await recaptcha.verify(action: 'login');

if (result.success) {
  print('Verification successful!');
  print('Token: ${result.token}');
  print('Score: ${result.score}');
  print('Challenge Type: ${result.challengeType}');
} else {
  print('Verification failed: ${result.errorMessage}');
}
```

### 3. Rotation CAPTCHA Widget

```dart
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

// Show rotation CAPTCHA dialog
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: RotationCaptchaWidget(
      imagePath: 'assets/your_image.jpg',
      tolerance: 20.0, // Degrees of tolerance
      onSuccess: () {
        print('CAPTCHA verified successfully!');
        Navigator.pop(context);
      },
      onFailed: () {
        print('CAPTCHA verification failed!');
      },
    ),
  ),
);
```

### 4. Using RecaptchaButton

```dart
RecaptchaButton(
  config: RecaptchaConfig(
    siteKey: 'YOUR_SITE_KEY',
    type: RecaptchaType.smart,
  ),
  action: 'submit_form',
  onVerified: (result) {
    print('Verified! Token: ${result.token}');
    // Submit your form
  },
  onError: (error) {
    print('Error: $error');
  },
  child: const Text('Submit Form'),
)
```

### 5. Using RecaptchaWidget

```dart
RecaptchaWidget(
  config: RecaptchaConfig(
    siteKey: 'YOUR_SITE_KEY',
    type: RecaptchaType.traditional,
  ),
  action: 'login',
  onResult: (result) {
    if (result.success) {
      print('Verification successful!');
    }
  },
  onError: (error) {
    print('Error: $error');
  },
)
```

### 6. Form Integration with RecaptchaFormField

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
      ),
      RecaptchaFormField(
        config: RecaptchaConfig(
          siteKey: 'YOUR_SITE_KEY',
          type: RecaptchaType.smart,
        ),
        validator: (isVerified) {
          return isVerified == true ? null : 'Please verify you are human';
        },
        onVerified: (result) {
          print('reCAPTCHA verified!');
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Submit form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### 7. Biometric Authentication

```dart
// Check if biometric is available
final isAvailable = await recaptcha.isBiometricAvailable();

if (isAvailable) {
  // Perform biometric authentication
  final result = await recaptcha.verify(action: 'biometric_login');
  
  if (result.success) {
    print('Biometric authentication successful!');
  }
}
```

### 8. Behavioral Analysis

```dart
// Start behavioral analysis
await recaptcha.startBehavioralAnalysis();

// User interacts with your app...
await Future.delayed(Duration(seconds: 5));

// Stop and get results
final result = await recaptcha.stopBehavioralAnalysis();

if (result.success) {
  print('Behavioral analysis passed!');
  print('Score: ${result.score}');
}
```

### 9. Device Fingerprinting

```dart
// Get device fingerprint
final fingerprint = await recaptcha.getDeviceFingerprint();
print('Device Fingerprint: $fingerprint');

// Use for additional security checks
```

### 10. Custom Smart Verification

```dart
// Initialize with custom config
await recaptcha.initialize(
  RecaptchaConfig(
    siteKey: 'YOUR_SITE_KEY',
    type: RecaptchaType.smart,
    enableBiometric: true,
    enableBehavioralAnalysis: true,
    enableDeviceFingerprinting: true,
    difficulty: ChallengeDifficulty.medium,
  ),
);

// Perform smart verification
final result = await recaptcha.verify(action: 'sensitive_action');

// Smart verification will automatically choose:
// - Invisible verification for low-risk users
// - Biometric for medium-risk users
// - Pattern challenges for high-risk users
```

## Configuration Options

### RecaptchaConfig

```dart
RecaptchaConfig(
  siteKey: 'YOUR_SITE_KEY',           // Required: Your reCAPTCHA site key
  type: RecaptchaType.smart,          // Type of reCAPTCHA
  enableBiometric: true,              // Enable biometric authentication
  enableBehavioralAnalysis: true,     // Enable behavioral analysis
  enableDeviceFingerprinting: true,   // Enable device fingerprinting
  difficulty: ChallengeDifficulty.medium, // Challenge difficulty
)
```

### RecaptchaType Options

```dart
enum RecaptchaType {
  traditional,  // Traditional reCAPTCHA challenges
  invisible,    // Invisible verification
  biometric,    // Biometric authentication only
  behavioral,   // Behavioral analysis only
  smart,        // Adaptive challenge selection (recommended)
}
```

### ChallengeDifficulty Options

```dart
enum ChallengeDifficulty {
  easy,    // Easy challenges
  medium,  // Medium difficulty (default)
  hard,    // Hard challenges
}
```

## Rotation CAPTCHA

### Basic Usage

```dart
RotationCaptchaWidget(
  imagePath: 'assets/image.jpg',
  tolerance: 15.0,  // Default: 15 degrees
  animationDuration: Duration(milliseconds: 300),
  onSuccess: () {
    print('Success!');
  },
  onFailed: () {
    print('Failed!');
  },
)
```

### Choosing the Right Image

For best results, use images with:
- Clear, recognizable details
- Distinct lines or patterns (e.g., tree trunk, building, animals)
- Good contrast
- Not too simple or too complex

✅ **Good Examples:**
- Animal photos (dog, cat, bird)
- Buildings and architecture
- Trees and plants
- Objects with clear lines

❌ **Bad Examples:**
- Uniform images (blue sky, plain wall)
- Very complex/busy images
- Low contrast images

### Adding Images to Assets

1. Add your images to the `assets` folder
2. Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/captcha_image1.jpg
    - assets/captcha_image2.jpg
```

## API Reference

### FlutterRecaptcha Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `initialize(config)` | Initialize reCAPTCHA with configuration | `Future<bool>` |
| `verify({action})` | Perform verification | `Future<RecaptchaResult>` |
| `isBiometricAvailable()` | Check if biometric is available | `Future<bool>` |
| `startBehavioralAnalysis()` | Start behavioral analysis | `Future<void>` |
| `stopBehavioralAnalysis()` | Stop and get behavioral results | `Future<RecaptchaResult>` |
| `getDeviceFingerprint()` | Get device fingerprint | `Future<String>` |
| `reset()` | Reset reCAPTCHA state | `Future<void>` |

### RecaptchaResult Properties

```dart
class RecaptchaResult {
  final bool success;              // Verification success status
  final String? token;             // Verification token
  final double? score;             // Risk score (0.0 - 1.0)
  final String? challengeType;     // Type of challenge used
  final String? errorMessage;      // Error message if failed
  final Map<String, dynamic>? metadata; // Additional metadata
}
```

## Examples

### Complete Login Form Example

```dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _recaptcha = FlutterRecaptcha.instance;
  bool _isRecaptchaVerified = false;

  @override
  void initState() {
    super.initState();
    _initializeRecaptcha();
  }

  Future<void> _initializeRecaptcha() async {
    await _recaptcha.initialize(
      RecaptchaConfig(
        siteKey: 'YOUR_SITE_KEY',
        type: RecaptchaType.smart,
        enableBiometric: true,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isRecaptchaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please verify reCAPTCHA')),
      );
      return;
    }

    // Proceed with login
    print('Login successful!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 24),
              RecaptchaWidget(
                config: RecaptchaConfig(
                  siteKey: 'YOUR_SITE_KEY',
                  type: RecaptchaType.smart,
                ),
                onResult: (result) {
                  setState(() {
                    _isRecaptchaVerified = result.success;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Rotation CAPTCHA in Dialog Example

```dart
void showRotationCaptcha(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: RotationCaptchaWidget(
        imagePath: 'assets/dog.jpg',
        tolerance: 20.0,
        onSuccess: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Verification successful!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onFailed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✗ Verification failed. Try again.'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    ),
  );
}
```

## Running the Example

To see all features in action:

```bash
cd example
flutter run
```

The example app includes:
- Smart reCAPTCHA demo with all challenge types
- Rotation CAPTCHA demo
- Login form integration
- Biometric authentication demo

## Troubleshooting

### Android Issues

**Issue:** Biometric errors on Android

**Solution:** Ensure you have added the biometric dependency and permissions:

```gradle
// Already included in the plugin
implementation("androidx.biometric:biometric:1.2.0-alpha05")
```

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

**Issue:** Build fails with "Unresolved reference 'biometric'"

**Solution:** Run:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd .. && flutter run
```

### iOS Issues

**Issue:** Biometric not working on iOS

**Solution:** Add Face ID usage description to `Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>We need to verify your identity using Face ID</string>
```

### General Issues

**Issue:** Images not loading in Rotation CAPTCHA

**Solution:** Ensure images are added to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/
```

## Security Considerations

1. **Never expose your secret key** in client-side code
2. **Always verify tokens on your server** before granting access
3. **Use HTTPS** for all API communications
4. **Implement rate limiting** on your backend
5. **Monitor for suspicious patterns** in verification attempts
6. **Rotate your keys regularly** for production apps

## Performance Tips

1. Initialize reCAPTCHA early in your app lifecycle
2. Use `RecaptchaType.smart` for best user experience
3. Cache device fingerprints when appropriate
4. Implement proper error handling and retry logic
5. Use appropriate challenge difficulty based on your security needs

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or suggestions:
- Open an issue on [GitHub](https://github.com/yourusername/flutter_recaptcha/issues)
- Check the [documentation](https://github.com/yourusername/flutter_recaptcha/wiki)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Additional Resources

- [Rotation CAPTCHA Guide](ROTATION_CAPTCHA_README.md)
- [Setup Guide](SETUP_GUIDE.md)
- [How It Works](HOW_IT_WORKS.md)
- [API Documentation](https://pub.dev/documentation/flutter_recaptcha/latest/)

---

Made with ❤️ by the Flutter community
