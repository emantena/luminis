const crypto = require('crypto');
const express = require('express');

const state = require('../state');
const { sendError } = require('../errors');
const { requireAuth } = require('../authMiddleware');

const router = express.Router();

const PERIOD_TYPES = new Set(['monthly', 'annual']);
const METRIC_TYPES = new Set(['books_read', 'pages_read']);
const STATUSES = new Set(['active', 'completed', 'cancelled']);

function todayDateOnly() {
  return process.env.MOCK_API_TODAY || '2026-08-17';
}

function nowIso() {
  return new Date(`${todayDateOnly()}T12:00:00.000Z`).toISOString();
}

function isDateOnly(value) {
  return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value);
}

function parseDateOnly(value) {
  return new Date(`${value}T00:00:00.000Z`);
}

function daysBetween(start, end) {
  const millisecondsPerDay = 24 * 60 * 60 * 1000;
  return Math.round((parseDateOnly(end) - parseDateOnly(start)) / millisecondsPerDay);
}

function defaultContributors(goal, value) {
  if (value <= 0) return [];
  if (goal.metricType === 'books_read') {
    if (value <= 1) {
      return [
        {
          title: 'Memorias Postumas de Bras Cubas',
          value: 1,
          description: 'Leitura concluida no periodo.',
        },
      ];
    }
    return [
      {
        title: 'Memorias Postumas de Bras Cubas',
        value: value - 1,
        description: 'Leitura concluida no periodo.',
      },
      {
        title: 'Dom Casmurro',
        value: 1,
        description: 'Releitura concluida conta como nova leitura.',
      },
    ];
  }
  return [
    {
      title: 'Dom Casmurro',
      value,
      description: 'Paginas novas lidas no periodo.',
    },
  ];
}

function calculatedValue(goal) {
  return Number.isInteger(goal.mockProgressValue) ? goal.mockProgressValue : goal.metricType === 'pages_read' ? 120 : 2;
}

function withCurrentStatus(goal) {
  if (goal.status !== 'active') return goal;
  const currentValue = calculatedValue(goal);
  if (currentValue < goal.targetValue) return goal;
  goal.status = 'completed';
  goal.completedAt = goal.completedAt || nowIso();
  goal.updatedAt = nowIso();
  return goal;
}

function progressFor(goal) {
  const currentValue = calculatedValue(goal);
  const remainingValue = Math.max(goal.targetValue - currentValue, 0);
  const bonusValue = Math.max(currentValue - goal.targetValue, 0);
  const percentage = goal.targetValue > 0 ? Math.min((currentValue / goal.targetValue) * 100, 100) : 0;
  const isReached = currentValue >= goal.targetValue;
  const isExpired = goal.status === 'active' && !isReached && parseDateOnly(todayDateOnly()) > parseDateOnly(goal.endsOn);
  return {
    currentValue,
    percentage: Math.round(percentage * 100) / 100,
    remainingValue,
    remainingDays: Math.max(0, daysBetween(todayDateOnly(), goal.endsOn)),
    bonusValue,
    isReached,
    isExceeded: bonusValue > 0,
    isExpired,
    needsAttention: isExpired,
    contributors: goal.mockContributors || defaultContributors(goal, currentValue),
    calculatedAt: nowIso(),
  };
}

function toResponse(goal) {
  return {
    id: goal.id,
    periodType: goal.periodType,
    metricType: goal.metricType,
    status: goal.status,
    targetValue: goal.targetValue,
    startsOn: goal.startsOn,
    endsOn: goal.endsOn,
    isPublic: goal.isPublic,
    completedAt: goal.completedAt || null,
    cancelledAt: goal.cancelledAt || null,
    createdAt: goal.createdAt,
    updatedAt: goal.updatedAt,
    progress: progressFor(goal),
  };
}

function requireGoal(req, res) {
  const goal = state.readingGoals.find(
    (candidate) => candidate.id === req.params.readingGoalId && candidate.userId === req.currentUserId,
  );
  if (!goal || goal.deletedAt) {
    sendError(req, res, 404, 'reading_goal.not_found', 'Meta nao encontrada.');
    return null;
  }
  return goal;
}

function hasDuplicateGoal({ userId, periodType, metricType, startsOn, endsOn, exceptId = null }) {
  return state.readingGoals.some(
    (goal) =>
      goal.id !== exceptId &&
      goal.userId === userId &&
      !goal.deletedAt &&
      goal.status !== 'cancelled' &&
      goal.periodType === periodType &&
      goal.metricType === metricType &&
      goal.startsOn === startsOn &&
      goal.endsOn === endsOn,
  );
}

function validateCreate(body) {
  const errors = {};
  if (!PERIOD_TYPES.has(body.periodType)) errors.periodType = ['periodType e invalido.'];
  if (!METRIC_TYPES.has(body.metricType)) errors.metricType = ['metricType e invalido.'];
  if (!Number.isInteger(body.targetValue) || body.targetValue <= 0) errors.targetValue = ['Informe um alvo maior que zero.'];
  if (!isDateOnly(body.startsOn)) errors.startsOn = ['startsOn deve usar YYYY-MM-DD.'];
  if (!isDateOnly(body.endsOn)) errors.endsOn = ['endsOn deve usar YYYY-MM-DD.'];
  if (isDateOnly(body.startsOn) && isDateOnly(body.endsOn) && parseDateOnly(body.endsOn) < parseDateOnly(body.startsOn)) {
    errors.endsOn = ['endsOn deve ser maior ou igual a startsOn.'];
  }
  if (body.isPublic !== undefined && typeof body.isPublic !== 'boolean') errors.isPublic = ['isPublic deve ser booleano.'];
  return errors;
}

function validatePatch(body) {
  const errors = {};
  const allowedKeys = ['targetValue', 'startsOn', 'endsOn', 'isPublic'];
  const suppliedKeys = Object.keys(body).filter((key) => body[key] !== undefined);
  if (suppliedKeys.length === 0) errors.body = ['Informe ao menos um campo.'];
  for (const key of suppliedKeys) {
    if (!allowedKeys.includes(key)) errors[key] = [`${key} nao pode ser alterado neste endpoint.`];
  }
  if (body.targetValue !== undefined && (!Number.isInteger(body.targetValue) || body.targetValue <= 0)) {
    errors.targetValue = ['Informe um alvo maior que zero.'];
  }
  if (body.startsOn !== undefined && !isDateOnly(body.startsOn)) errors.startsOn = ['startsOn deve usar YYYY-MM-DD.'];
  if (body.endsOn !== undefined && !isDateOnly(body.endsOn)) errors.endsOn = ['endsOn deve usar YYYY-MM-DD.'];
  if (body.isPublic !== undefined && typeof body.isPublic !== 'boolean') errors.isPublic = ['isPublic deve ser booleano.'];
  return errors;
}

function sortGoals(a, b) {
  const aProgress = progressFor(a);
  const bProgress = progressFor(b);
  if (aProgress.needsAttention !== bProgress.needsAttention) return aProgress.needsAttention ? -1 : 1;
  if (a.status !== b.status) {
    if (a.status === 'active') return -1;
    if (b.status === 'active') return 1;
  }
  return Date.parse(b.updatedAt) - Date.parse(a.updatedAt);
}

router.get('/reading-goals', requireAuth, (req, res) => {
  const errors = {};
  const { status, periodType, metricType, year } = req.query;
  if (status !== undefined && !STATUSES.has(status)) errors.status = ['status e invalido.'];
  if (periodType !== undefined && !PERIOD_TYPES.has(periodType)) errors.periodType = ['periodType e invalido.'];
  if (metricType !== undefined && !METRIC_TYPES.has(metricType)) errors.metricType = ['metricType e invalido.'];
  if (year !== undefined && !/^\d{4}$/.test(String(year))) errors.year = ['year deve ter quatro digitos.'];
  if (Object.keys(errors).length > 0) return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);

  const items = state.readingGoals
    .filter((goal) => goal.userId === req.currentUserId && !goal.deletedAt)
    .filter((goal) => status === undefined ? goal.status !== 'cancelled' : goal.status === status)
    .filter((goal) => periodType === undefined || goal.periodType === periodType)
    .filter((goal) => metricType === undefined || goal.metricType === metricType)
    .filter((goal) => {
      if (year === undefined) return true;
      const start = `${year}-01-01`;
      const end = `${year}-12-31`;
      return goal.startsOn <= end && goal.endsOn >= start;
    })
    .sort(sortGoals)
    .map(toResponse);

  return res.status(200).json({ items });
});

router.post('/reading-goals', requireAuth, (req, res) => {
  const body = req.body || {};
  const errors = validateCreate(body);
  if (Object.keys(errors).length > 0) return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  if (
    hasDuplicateGoal({
      userId: req.currentUserId,
      periodType: body.periodType,
      metricType: body.metricType,
      startsOn: body.startsOn,
      endsOn: body.endsOn,
    })
  ) {
    return sendError(req, res, 409, 'reading_goal.duplicate_goal', 'Ja existe uma meta para este periodo.');
  }

  const now = nowIso();
  const goal = {
    id: crypto.randomUUID(),
    userId: req.currentUserId,
    periodType: body.periodType,
    metricType: body.metricType,
    status: 'active',
    targetValue: body.targetValue,
    startsOn: body.startsOn,
    endsOn: body.endsOn,
    isPublic: body.isPublic === true,
    completedAt: null,
    cancelledAt: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    mockProgressValue: body.metricType === 'pages_read' ? 120 : 2,
  };
  state.readingGoals.push(withCurrentStatus(goal));
  return res.status(201).json(toResponse(goal));
});

router.get('/reading-goals/:readingGoalId', requireAuth, (req, res) => {
  const goal = requireGoal(req, res);
  if (!goal) return;
  return res.status(200).json(toResponse(goal));
});

router.patch('/reading-goals/:readingGoalId', requireAuth, (req, res) => {
  const goal = requireGoal(req, res);
  if (!goal) return;
  const body = req.body || {};
  const errors = validatePatch(body);
  const nextStartsOn = body.startsOn || goal.startsOn;
  const nextEndsOn = body.endsOn || goal.endsOn;
  if (parseDateOnly(nextEndsOn) < parseDateOnly(nextStartsOn)) {
    errors.endsOn = ['endsOn deve ser maior ou igual a startsOn.'];
  }
  if (Object.keys(errors).length > 0) return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  if (goal.status !== 'active') {
    return sendError(req, res, 409, 'reading_goal.not_editable', 'Somente metas ativas podem ser editadas.');
  }
  if (
    hasDuplicateGoal({
      userId: req.currentUserId,
      periodType: goal.periodType,
      metricType: goal.metricType,
      startsOn: nextStartsOn,
      endsOn: nextEndsOn,
      exceptId: goal.id,
    })
  ) {
    return sendError(req, res, 409, 'reading_goal.duplicate_goal', 'Ja existe uma meta para este periodo.');
  }

  if (body.targetValue !== undefined) goal.targetValue = body.targetValue;
  if (body.startsOn !== undefined) goal.startsOn = body.startsOn;
  if (body.endsOn !== undefined) goal.endsOn = body.endsOn;
  if (body.isPublic !== undefined) goal.isPublic = body.isPublic;
  goal.updatedAt = nowIso();
  return res.status(200).json(toResponse(withCurrentStatus(goal)));
});

router.post('/reading-goals/:readingGoalId/cancel', requireAuth, (req, res) => {
  const goal = requireGoal(req, res);
  if (!goal) return;
  if (goal.status !== 'active') {
    return sendError(req, res, 409, 'reading_goal.not_cancellable', 'Somente metas ativas podem ser canceladas.');
  }
  goal.status = 'cancelled';
  goal.cancelledAt = nowIso();
  goal.updatedAt = goal.cancelledAt;
  return res.status(200).json(toResponse(goal));
});

router.get('/reading-goals/:readingGoalId/progress', requireAuth, (req, res) => {
  const goal = requireGoal(req, res);
  if (!goal) return;
  const progress = progressFor(goal);
  return res.status(200).json({
    readingGoalId: goal.id,
    metricType: goal.metricType,
    targetValue: goal.targetValue,
    ...progress,
  });
});

module.exports = router;
