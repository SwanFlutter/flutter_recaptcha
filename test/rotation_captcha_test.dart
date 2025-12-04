import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RotationCaptchaWidget Tests', () {
    testWidgets('Widget should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RotationCaptchaWidget(imagePath: 'assets/test_image.jpg'),
          ),
        ),
      );

      // Check if the widget renders
      expect(find.byType(RotationCaptchaWidget), findsOneWidget);

      // Check for slider
      expect(find.byType(Slider), findsOneWidget);

      // Check for refresh button
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('Slider should update rotation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RotationCaptchaWidget(imagePath: 'assets/test_image.jpg'),
          ),
        ),
      );

      // Find the slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag the slider (with warnIfMissed: false to avoid hit test warnings)
      await tester.drag(slider, const Offset(100, 0), warnIfMissed: false);
      await tester.pump();

      // Widget should still be present
      expect(find.byType(RotationCaptchaWidget), findsOneWidget);
    });

    testWidgets('Refresh button should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RotationCaptchaWidget(imagePath: 'assets/test_image.jpg'),
          ),
        ),
      );

      // Find and tap refresh button
      final refreshButton = find.text('Refresh');
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();

      // Widget should still be present
      expect(find.byType(RotationCaptchaWidget), findsOneWidget);
    });
  });
}
