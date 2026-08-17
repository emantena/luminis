import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luminis_app/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:luminis_app/features/goals/domain/entities/reading_goal.dart';
import 'package:luminis_app/shared/infrastructure/api_client.dart';

void main() {
  group('GoalRepositoryImpl', () {
    test('lista metas pela rota /reading-goals e mapeia enums wire', () async {
      final repository = GoalRepositoryImpl(
        ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            expect(request.method, 'GET');
            expect(
              request.url.toString(),
              'http://mock.local/api/reading-goals',
            );
            expect(request.headers['Authorization'], 'Bearer token-123');
            return http.Response(
              jsonEncode({
                'items': [_goalJson()],
              }),
              200,
            );
          }),
        ),
        bearerToken: 'token-123',
      );

      final goals = await repository.listGoals();

      expect(goals, hasLength(1));
      expect(goals.single.goal.periodType, GoalPeriodType.yearly);
      expect(goals.single.goal.status, GoalStatus.canceled);
      expect(goals.single.currentValue, 8);
      expect(goals.single.contributors.single.value, 8);
    });

    test('cria meta mensal enviando contrato de API', () async {
      final repository = GoalRepositoryImpl(
        ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            expect(request.method, 'POST');
            expect(
              request.url.toString(),
              'http://mock.local/api/reading-goals',
            );
            expect(jsonDecode(request.body), {
              'periodType': 'monthly',
              'metricType': 'pages_read',
              'targetValue': 500,
              'startsOn': '2026-08-01',
              'endsOn': '2026-08-31',
              'isPublic': false,
            });
            return http.Response(jsonEncode(_goalJson()), 201);
          }),
        ),
        now: () => DateTime.utc(2026, 8, 17),
      );

      final goal = await repository.createGoal(
        const ReadingGoalDraft(
          periodType: GoalPeriodType.monthly,
          metricType: GoalMetricType.pagesRead,
          targetValue: 500,
          isPublic: false,
        ),
      );

      expect(goal.goal.metricType, GoalMetricType.pagesRead);
    });

    test('edita meta sem enviar periodType nem metricType no PATCH', () async {
      final repository = GoalRepositoryImpl(
        ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(request.method, 'PATCH');
            expect(
              request.url.toString(),
              'http://mock.local/api/reading-goals/goal_1',
            );
            expect(
              body.keys,
              unorderedEquals([
                'targetValue',
                'startsOn',
                'endsOn',
                'isPublic',
              ]),
            );
            return http.Response(jsonEncode(_goalJson(targetValue: 9)), 200);
          }),
        ),
        now: () => DateTime.utc(2026, 1, 3),
      );

      final goal = await repository.updateGoal(
        readingGoalId: 'goal_1',
        draft: const ReadingGoalDraft(
          periodType: GoalPeriodType.yearly,
          metricType: GoalMetricType.booksRead,
          targetValue: 9,
          isPublic: true,
        ),
      );

      expect(goal.goal.targetValue, 9);
    });

    test('cancela meta pela acao explicita do contrato', () async {
      final repository = GoalRepositoryImpl(
        ApiClient(
          baseUrl: 'http://mock.local/api',
          httpClient: MockClient((request) async {
            expect(request.method, 'POST');
            expect(
              request.url.toString(),
              'http://mock.local/api/reading-goals/goal_1/cancel',
            );
            return http.Response(jsonEncode(_goalJson()), 200);
          }),
        ),
      );

      await repository.cancelGoal('goal_1');
    });
  });
}

Map<String, Object?> _goalJson({int targetValue = 12}) {
  return {
    'id': 'goal_1',
    'periodType': 'annual',
    'metricType': 'pages_read',
    'status': 'cancelled',
    'targetValue': targetValue,
    'startsOn': '2026-01-01',
    'endsOn': '2026-12-31',
    'isPublic': false,
    'completedAt': null,
    'cancelledAt': '2026-08-17T12:00:00.000Z',
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-08-17T12:00:00.000Z',
    'progress': {
      'currentValue': 8,
      'percentage': 66.67,
      'remainingValue': 4,
      'remainingDays': 136,
      'bonusValue': 0,
      'isReached': false,
      'isExceeded': false,
      'isExpired': false,
      'needsAttention': false,
      'contributors': [
        {
          'title': 'Dom Casmurro',
          'value': 8,
          'description': 'Paginas novas lidas no periodo.',
        },
      ],
    },
  };
}
