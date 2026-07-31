import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pnestaffapp/core/widgets/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders its label and fires onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Continue',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.byType(PrimaryButton));
      expect(tapped, isTrue);
    });

    testWidgets('shows a spinner and blocks taps while loading',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Continue',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });
  });
}
