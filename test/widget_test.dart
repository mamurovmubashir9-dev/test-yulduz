import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:imtixon_ilova/main.dart';

void main() {
  testWidgets('Shows role selection when signed out', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: ImtixonIlovaApp()));
    await tester.pumpAndSettle();

    expect(find.text('O\'qituvchi'), findsOneWidget);
    expect(find.text('O\'quvchi'), findsOneWidget);
  });
}
