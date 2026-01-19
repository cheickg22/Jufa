import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jufa_mobile/shared/widgets/jufa_widgets.dart';

void main() {
  group('JufaTextField', () {
    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaTextField(
              label: 'Email',
              hint: 'Enter your email',
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders without label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaTextField(
              hint: 'Enter value',
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (WidgetTester tester) async {
      String? changedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaTextField(
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test');
      expect(changedValue, 'test');
    });

    testWidgets('displays error text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaTextField(
              errorText: 'Invalid input',
            ),
          ),
        ),
      );

      expect(find.text('Invalid input'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaTextField(
              obscureText: true,
            ),
          ),
        ),
      );

      final finder = find.byType(TextFormField);
      expect(finder, findsOneWidget);
      
      final editableText = find.descendant(
        of: finder,
        matching: find.byType(EditableText),
      );
      final widget = tester.widget<EditableText>(editableText);
      expect(widget.obscureText, isTrue);
    });

    testWidgets('displays prefix and suffix icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaTextField(
              prefixIcon: Icon(Icons.email),
              suffixIcon: Icon(Icons.visibility),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('is disabled when enabled is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaTextField(
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });
  });

  group('JufaButton', () {
    testWidgets('renders with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaButton(
              text: 'Submit',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaButton(
              text: 'Submit',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaButton(
              text: 'Submit',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('disables button when isLoading is true', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaButton(
              text: 'Submit',
              isLoading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });

    testWidgets('renders outlined style when isOutlined is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaButton(
              text: 'Cancel',
              isOutlined: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('disables button when onPressed is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JufaButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
