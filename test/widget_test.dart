// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:roomix/main.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/providers/user_preferences_provider.dart';
import 'package:roomix/providers/utility_provider.dart';

void main() {
  testWidgets('Roomix app builds', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
          ChangeNotifierProvider(create: (_) => UtilityProvider()),
        ],
        child: const RoomixApp(),
      ),
    );

    // Allow splash timer to complete
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Basic smoke assertion
    expect(find.byType(RoomixApp), findsOneWidget);
  });
}
