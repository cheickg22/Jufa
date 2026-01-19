import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jufa_mobile/shared/widgets/offline_banner.dart';
import 'package:jufa_mobile/core/services/connectivity_service.dart';

void main() {
  group('OfflineBanner', () {
    testWidgets('shows nothing when online', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStreamProvider.overrideWith(
              (ref) => Stream.value(ConnectivityStatus.online),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  OfflineBanner(),
                  Expanded(child: Container()),
                ],
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('Mode hors-ligne'), findsNothing);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
    });

    testWidgets('shows banner when offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStreamProvider.overrideWith(
              (ref) => Stream.value(ConnectivityStatus.offline),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  OfflineBanner(),
                  Expanded(child: Container()),
                ],
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('Mode hors-ligne'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });
  });

  group('ConnectivityWrapper', () {
    testWidgets('wraps child with banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStreamProvider.overrideWith(
              (ref) => Stream.value(ConnectivityStatus.offline),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConnectivityWrapper(
                child: Center(child: Text('Content')),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Mode hors-ligne'), findsOneWidget);
    });
  });
}
