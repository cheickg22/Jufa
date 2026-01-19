import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jufa_mobile/features/auth/presentation/screens/login_screen.dart';

Widget createTestableWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('renders login form elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Bienvenue'), findsOneWidget);
      expect(find.text('Connectez-vous pour continuer'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('shows password visibility toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('validates empty phone field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer votre numéro'), findsOneWidget);
    });

    testWidgets('validates empty password field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      final phoneField = find.byType(TextFormField).first;
      await tester.enterText(phoneField, '+22370001234');
      
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
    });

    testWidgets('validates phone format', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      final phoneField = find.byType(TextFormField).first;
      await tester.enterText(phoneField, '123');
      
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Format invalide'), findsOneWidget);
    });

    testWidgets('has forgot password link', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });

    testWidgets('has register link', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Vous n'avez pas de compte ? "), findsOneWidget);
      expect(find.text("S'inscrire"), findsOneWidget);
    });

    testWidgets('renders JUFA logo', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('J'), findsOneWidget);
    });
  });
}
