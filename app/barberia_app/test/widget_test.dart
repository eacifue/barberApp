import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barberia_app/features/auth/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders app title', (WidgetTester tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: SplashScreen(),
    ));

    expect(find.text('Barbería App'), findsOneWidget);
  });
}
