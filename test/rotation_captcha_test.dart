import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_recaptcha/flutter_recaptcha.dart';
import 'package:flutter_test/flutter_test.dart';

// 1x1 transparent PNG
final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  group('RotationCaptchaWidget Tests', () {
    testWidgets('Widget should render correctly', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RotationCaptchaWidget(
                imageProvider: MemoryImage(kTransparentImage),
              ),
            ),
          ),
        );

        // Should show loading initially
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for image to load
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();

        // Check if the widget renders content
        expect(find.byType(RotationCaptchaWidget), findsOneWidget);
        // Custom slider thumb icon
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
        expect(find.text('Refresh'), findsOneWidget);
      });
    });

    testWidgets('Slider should update rotation', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RotationCaptchaWidget(
                imageProvider: MemoryImage(kTransparentImage),
              ),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();

        final sliderThumb = find.byIcon(Icons.arrow_forward);
        expect(sliderThumb, findsOneWidget);

        // Drag the slider
        await tester.drag(sliderThumb, const Offset(100, 0));
        await tester.pump();

        // Widget should still be present and interactive
        expect(find.byType(RotationCaptchaWidget), findsOneWidget);
      });
    });

    testWidgets('Refresh button should work', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RotationCaptchaWidget(
                imageProvider: MemoryImage(kTransparentImage),
              ),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();

        final refreshButton = find.text('Refresh');
        expect(refreshButton, findsOneWidget);

        await tester.tap(refreshButton);
        await tester.pump();

        // Should basically reset/re-render
        expect(find.byType(RotationCaptchaWidget), findsOneWidget);
      });
    });
  });
}
