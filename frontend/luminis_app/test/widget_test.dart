import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminis_app/features/auth/data/providers/auth_providers.dart';
import 'package:luminis_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:luminis_app/main.dart';

import 'features/auth/fakes/fake_auth_repository.dart';

void main() {
  testWidgets(
    'LuminisApp abre sem exceção, com tema e navegação aplicados, e inicia '
    'em Auth · Welcome quando desautenticado',
    (tester) async {
      final container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const LuminisApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    },
  );
}
