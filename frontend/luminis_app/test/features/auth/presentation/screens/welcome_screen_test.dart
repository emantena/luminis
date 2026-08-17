import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/app/theme/luminis_logo.dart';
import 'package:luminis_app/features/auth/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('prioriza a marca oficial sem repetir o nome em texto', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    final logo = tester.widget<LuminisLogo>(find.byType(LuminisLogo));

    expect(logo.height, 200);
    expect(find.text('Luminis'), findsNothing);
    expect(
      find.text(
        'Organize sua estante, acompanhe seu progresso e cumpra suas metas de leitura.',
      ),
      findsOneWidget,
    );
  });
}
