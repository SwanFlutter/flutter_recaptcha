# راهنمای راه‌اندازی پروژه

## مشکلات برطرف شده

### 1. خطای Biometric در Android ✅
**مشکل:** خطاهای "Unresolved reference 'biometric'" در کد Kotlin

**راه‌حل:** dependency زیر به `android/build.gradle` اضافه شد:
```gradle
implementation("androidx.biometric:biometric:1.2.0-alpha05")
```

### 2. اضافه شدن Rotation CAPTCHA ✅
یک ویجت جدید و جذاب برای تایید کاربر با ویژگی‌های زیر:
- نمایش یک تصویر واحد با قسمت داخلی چرخیده شده
- کاربر باید قسمت داخلی را بچرخاند تا با قسمت بیرونی تطابق پیدا کند
- مشابه CAPTCHA های محبوب
- رابط کاربری زیبا و کاربرپسند

## مراحل راه‌اندازی

### 1. نصب Dependencies
```bash
flutter pub get
cd example
flutter pub get
```

### 2. آماده‌سازی تصاویر CAPTCHA

تصویر نمونه در پوشه `assets` قرار دارد:
- `assets/dog_outer.jpg` - تصویر نمونه سگ

می‌توانید از هر تصویری استفاده کنید. برای بهترین نتیجه:
- از تصاویری با جزئیات واضح استفاده کنید
- تصاویر حیوانات، ساختمان‌ها، یا اشیاء با خطوط مشخص مناسب هستند
- از تصاویر یکنواخت یا بسیار پیچیده اجتناب کنید

### 3. اجرای Example
```bash
cd example
flutter run
```

## استفاده از Rotation CAPTCHA

```dart
import 'package:flutter_recaptcha/flutter_recaptcha.dart';

showDialog(
  context: context,
  builder: (context) => Dialog(
    child: RotationCaptchaWidget(
      imagePath: 'assets/your_image.jpg',
      tolerance: 20.0,
      onSuccess: () {
        print('تایید موفق!');
        Navigator.pop(context);
      },
      onFailed: () {
        print('تایید ناموفق!');
      },
    ),
  ),
);
```

## ساختار فایل‌ها

```
flutter_recaptcha/
├── lib/
│   ├── flutter_recaptcha.dart
│   └── widgets/
│       ├── recaptcha_widget.dart
│       └── rotation_captcha_widget.dart (جدید!)
├── example/
│   └── lib/
│       ├── main.dart (به‌روز شده)
│       ├── smart_demo_page.dart
│       └── rotation_captcha_demo.dart (جدید!)
├── assets/
│   ├── outer_circle.svg
│   ├── inner_circle.svg
│   ├── dog_outer.jpg
│   └── dog_inner.jpg
├── android/
│   └── build.gradle (به‌روز شده)
├── generate_images.html (جدید!)
└── README.md (به‌روز شده)
```

## نکات مهم

1. **تصاویر:** تصویر نمونه در پوشه assets موجود است، می‌توانید از تصاویر خود استفاده کنید
2. **Android Build:** اگر با خطای biometric مواجه شدید، `flutter clean` و سپس `flutter pub get` را اجرا کنید
3. **تست‌ها:** تست‌ها به دلیل نبود تصاویر در محیط تست fail می‌شوند، این طبیعی است
4. **نحوه کار:** قسمت داخلی تصویر چرخانده می‌شود و کاربر باید آن را به حالت اصلی برگرداند

## مستندات بیشتر

- [README.md](README.md) - مستندات کامل پروژه
- [ROTATION_CAPTCHA_README.md](ROTATION_CAPTCHA_README.md) - راهنمای Rotation CAPTCHA
- [CHANGELOG.md](CHANGELOG.md) - تغییرات نسخه‌ها
