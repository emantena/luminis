const express = require('express');

const state = require('../state');
const { sendError } = require('../errors');
const { requireAuth } = require('../authMiddleware');
const {
  registerProgress,
  removePlan,
  savePlan,
  toReadingStateResponse,
} = require('../readingHelpers');

const router = express.Router();

function requireActiveItem(req, res) {
  const item = state.bookshelfItems.find(
    (candidate) => candidate.id === req.params.bookshelfItemId && candidate.userId === req.currentUserId && !candidate.removedAt,
  );
  if (!item) {
    sendError(req, res, 404, 'bookshelf.item_not_found', 'Item da estante nao encontrado.');
    return null;
  }
  return item;
}

router.get('/bookshelf-items/:bookshelfItemId/reading-state', requireAuth, (req, res) => {
  const item = requireActiveItem(req, res);
  if (!item) return;
  return res.status(200).json(toReadingStateResponse(item));
});

router.put('/bookshelf-items/:bookshelfItemId/reading-plan', requireAuth, (req, res) => {
  const item = requireActiveItem(req, res);
  if (!item) return;
  const result = savePlan(item, req.body || {});
  if (result.errors) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', result.errors);
  }
  return res.status(200).json(result.plan);
});

router.delete('/bookshelf-items/:bookshelfItemId/reading-plan', requireAuth, (req, res) => {
  const item = requireActiveItem(req, res);
  if (!item) return;
  removePlan(item);
  return res.status(204).send();
});

router.post('/reading-sessions/:readingSessionId/progress', requireAuth, (req, res) => {
  const session = state.readingSessions.find((candidate) => candidate.id === req.params.readingSessionId);
  const item = session && state.bookshelfItems.find(
    (candidate) => candidate.id === session.bookshelfItemId && candidate.userId === req.currentUserId && !candidate.removedAt,
  );
  if (!session || !item) {
    return sendError(req, res, 404, 'reading.session_not_found', 'Sessao de leitura nao encontrada.');
  }
  if (session.status !== 'active') {
    return sendError(req, res, 409, 'reading.session_not_active', 'Retome a leitura antes de registrar progresso.');
  }

  const result = registerProgress(session, req.body || {});
  if (result.conflict) {
    return sendError(req, res, 409, 'reading.progress_regression', result.conflict);
  }
  if (result.errors) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', result.errors);
  }

  return res.status(201).json({
    id: result.entry.id,
    readingSessionId: result.entry.readingSessionId,
    pageNumber: result.entry.pageNumber,
    percentage: result.entry.percentage,
    note: result.entry.note,
    isPublic: result.entry.isPublic,
    createdAt: result.entry.createdAt,
    readingStatusAfterProgress: result.item.readingStatus,
    completedReading: result.completedReading,
  });
});

module.exports = router;
