import 'package:flutter_test/flutter_test.dart';

import 'package:steam_achievement_tracker/main.dart';

void main() {
  testWidgets('shows login screen when no session is restored', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(initialSteamId: null));

    expect(find.text('STEAMER'), findsOneWidget);
    expect(
      find.text('Track your Steam profile, library, and achievements in one place.'),
      findsOneWidget,
    );
    expect(find.text('Login'), findsOneWidget);
  });
}
