const crypto = require('crypto');
const express = require('express');

const state = require('../state');
const { sendError } = require('../errors');
const { requireAuth } = require('../authMiddleware');
const { applyReadingStatus, toBookshelfItemResponse } = require('../readingHelpers');

const router = express.Router();
const READING_STATUSES = new Set(['want_to_read', 'reading', 'paused', 'read', 'rereading', 'abandoned']);
const TAG_KEYS = ['isFavorite', 'isOwned', 'isWished', 'isBorrowed', 'isLent', 'isEbook', 'isAudiobook'];

function defaultTags() {
  return Object.fromEntries(TAG_KEYS.map((key) => [key, false]));
}

function parsePagination(req, res) {
  const page = req.query.page === undefined ? 1 : Number(req.query.page);
  const limit = req.query.limit === undefined ? 20 : Number(req.query.limit);
  const errors = {};
  if (!Number.isInteger(page) || page < 1) errors.page = ['page deve ser um inteiro positivo.'];
  if (!Number.isInteger(limit) || limit < 1 || limit > 50) errors.limit = ['limit deve ser um inteiro entre 1 e 50.'];
  if (Object.keys(errors).length > 0) {
    sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
    return null;
  }
  return { page, limit };
}

function findBook(bookId) {
  return state.catalogBooks.find((book) => book.id === bookId);
}

function toBookSummary(book) {
  return { id: book.id, title: book.title, subtitle: book.subtitle || null, authors: book.authors };
}

function toEditionSummary(edition) {
  return {
    id: edition.id,
    title: edition.title,
    coverUrl: edition.coverUrl || null,
    pageCount: edition.pageCount || null,
    language: edition.language || null,
    format: edition.format || null,
  };
}

function toDraft(draft) {
  return {
    id: draft.id,
    title: draft.title,
    authors: draft.authors,
    edition: draft.edition || null,
    status: 'local',
    createdAt: draft.createdAt,
  };
}

function toResponse(item) {
  const base = {
    id: item.id,
    target: item.target,
    readingStatus: item.readingStatus,
    tags: item.tags,
    startedAt: item.startedAt || null,
    finishedAt: item.finishedAt || null,
    addedAt: item.addedAt,
    updatedAt: item.updatedAt,
  };
  if (item.target.type === 'book') {
    const book = findBook(item.target.bookId);
    const edition = book && book.editions.find((candidate) => candidate.id === item.target.editionId);
    return { ...base, book: book ? toBookSummary(book) : null, edition: edition ? toEditionSummary(edition) : null, draft: null };
  }
  const draft = state.bookDrafts.find((candidate) => candidate.id === item.target.userBookDraftId && candidate.userId === item.userId);
  return { ...base, book: null, edition: null, draft: draft ? toDraft(draft) : null };
}

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

function parseFilters(req, res) {
  const filters = {};
  const errors = {};
  if (req.query.readingStatus !== undefined) {
    if (!READING_STATUSES.has(req.query.readingStatus)) errors.readingStatus = ['readingStatus e invalido.'];
    else filters.readingStatus = req.query.readingStatus;
  }
  for (const key of TAG_KEYS) {
    if (req.query[key] === undefined) continue;
    if (req.query[key] !== 'true' && req.query[key] !== 'false') errors[key] = [`${key} deve ser true ou false.`];
    else filters[key] = req.query[key] === 'true';
  }
  if (Object.keys(errors).length > 0) {
    sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
    return null;
  }
  return filters;
}

// GET /api/bookshelf-items
router.get('/bookshelf-items', requireAuth, (req, res) => {
  const filters = parseFilters(req, res);
  if (!filters) return;
  const pagination = parsePagination(req, res);
  if (!pagination) return;

  const matches = state.bookshelfItems
    .filter((item) => item.userId === req.currentUserId && !item.removedAt)
    .filter((item) => {
      if (filters.readingStatus && item.readingStatus !== filters.readingStatus) return false;
      return TAG_KEYS.every((key) => filters[key] === undefined || item.tags[key] === filters[key]);
    })
    .sort((a, b) => Date.parse(b.updatedAt) - Date.parse(a.updatedAt) || Date.parse(b.addedAt) - Date.parse(a.addedAt));
  const start = (pagination.page - 1) * pagination.limit;
  const items = matches.slice(start, start + pagination.limit).map(toBookshelfItemResponse);
  return res.status(200).json({
    items,
    page: pagination.page,
    limit: pagination.limit,
    hasNextPage: start + items.length < matches.length,
  });
});

// POST /api/bookshelf-items
router.post('/bookshelf-items', requireAuth, (req, res) => {
  const { bookId, editionId, userBookDraftId, readingStatus } = req.body || {};
  const usesBook = typeof bookId === 'string' || typeof editionId === 'string';
  const usesDraft = typeof userBookDraftId === 'string';
  const errors = {};
  if (usesBook === usesDraft) errors.target = ['Informe um livro global ou um cadastro local.'];
  if (usesBook && (typeof bookId !== 'string' || typeof editionId !== 'string')) errors.editionId = ['bookId e editionId sao obrigatorios juntos.'];
  if (!READING_STATUSES.has(readingStatus)) errors.readingStatus = ['readingStatus e obrigatorio e invalido.'];
  if (Object.keys(errors).length > 0) return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);

  let target;
  if (usesBook) {
    const book = findBook(bookId);
    const edition = book && book.editions.find((candidate) => candidate.id === editionId);
    if (!edition) return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', { editionId: ['editionId deve pertencer a bookId.'] });
    target = { type: 'book', bookId, editionId };
  } else {
    const draft = state.bookDrafts.find((candidate) => candidate.id === userBookDraftId && candidate.userId === req.currentUserId);
    if (!draft) return sendError(req, res, 404, 'book_draft.not_found', 'Cadastro local nao encontrado.');
    target = { type: 'draft', userBookDraftId };
  }

  const duplicate = state.bookshelfItems.some((item) =>
    item.userId === req.currentUserId && !item.removedAt &&
    (target.type === 'book'
      ? item.target.type === 'book' && item.target.editionId === target.editionId
      : item.target.type === 'draft' && item.target.userBookDraftId === target.userBookDraftId),
  );
  if (duplicate) return sendError(req, res, 409, 'bookshelf.item_already_exists', 'Este item ja esta na sua estante.');

  const now = new Date().toISOString();
  const item = {
    id: crypto.randomUUID(), userId: req.currentUserId, target, readingStatus,
    tags: defaultTags(), addedAt: now, updatedAt: now, removedAt: null,
    startedAt: readingStatus === 'reading' || readingStatus === 'rereading' ? now : null,
    finishedAt: readingStatus === 'read' ? now : null,
  };
  state.bookshelfItems.push(item);
  applyReadingStatus(item, readingStatus);
  return res.status(201).json(toBookshelfItemResponse(item));
});

// PATCH /api/bookshelf-items/:bookshelfItemId/tags
router.patch('/bookshelf-items/:bookshelfItemId/tags', requireAuth, (req, res) => {
  const body = req.body || {};
  const suppliedKeys = TAG_KEYS.filter((key) => Object.prototype.hasOwnProperty.call(body, key));
  const errors = {};
  if (suppliedKeys.length === 0) errors.tags = ['Informe ao menos uma etiqueta.'];
  for (const key of suppliedKeys) if (typeof body[key] !== 'boolean') errors[key] = [`${key} deve ser booleano.`];
  if (Object.keys(errors).length > 0) return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  const item = requireActiveItem(req, res);
  if (!item) return;
  for (const key of suppliedKeys) item.tags[key] = body[key];
  item.updatedAt = new Date().toISOString();
  return res.status(200).json(toBookshelfItemResponse(item));
});

// PATCH /api/bookshelf-items/:bookshelfItemId/reading-status
router.patch('/bookshelf-items/:bookshelfItemId/reading-status', requireAuth, (req, res) => {
  const { readingStatus, sessionAction } = req.body || {};
  if (!READING_STATUSES.has(readingStatus)) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', { readingStatus: ['readingStatus e obrigatorio e invalido.'] });
  }
  if (sessionAction !== undefined && sessionAction !== 'keep_paused' && sessionAction !== 'interrupt') {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', { sessionAction: ['sessionAction e invalido.'] });
  }
  const item = requireActiveItem(req, res);
  if (!item) return;
  const result = applyReadingStatus(item, readingStatus, sessionAction);
  if (result.error) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', {
      [result.error.field]: [result.error.message],
    });
  }
  return res.status(200).json(toBookshelfItemResponse(item));
});

// DELETE /api/bookshelf-items/:bookshelfItemId (soft delete)
router.delete('/bookshelf-items/:bookshelfItemId', requireAuth, (req, res) => {
  const item = requireActiveItem(req, res);
  if (!item) return;
  applyReadingStatus(item, 'want_to_read', 'interrupt');
  item.removedAt = new Date().toISOString();
  item.updatedAt = item.removedAt;
  return res.status(204).send();
});

module.exports = router;
