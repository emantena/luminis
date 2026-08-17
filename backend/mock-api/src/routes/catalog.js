const crypto = require('crypto');
const express = require('express');

const state = require('../state');
const { sendError } = require('../errors');
const { isNonEmptyString } = require('../validators');
const { requireAuth } = require('../authMiddleware');

const router = express.Router();
const SEARCH_TYPES = new Set(['all', 'title', 'author', 'publisher', 'subject', 'isbn']);
const PROVIDER_UNAVAILABLE_QUERY = '__provider_unavailable__';

function parsePagination(req, res) {
  const page = req.query.page === undefined ? 1 : Number(req.query.page);
  const limit = req.query.limit === undefined ? 20 : Number(req.query.limit);
  const errors = {};

  if (!Number.isInteger(page) || page < 1) {
    errors.page = ['page deve ser um inteiro positivo.'];
  }
  if (!Number.isInteger(limit) || limit < 1 || limit > 50) {
    errors.limit = ['limit deve ser um inteiro entre 1 e 50.'];
  }
  if (Object.keys(errors).length > 0) {
    sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
    return null;
  }
  return { page, limit };
}

function toSearchBook(book) {
  return {
    id: book.id,
    title: book.title,
    subtitle: book.subtitle || null,
    authors: book.authors,
  };
}

function toEdition(edition) {
  return {
    id: edition.id,
    title: edition.title,
    subtitle: edition.subtitle || null,
    coverUrl: edition.coverUrl || null,
    publisher: edition.publisher,
    publishedYear: edition.publishedYear || null,
    language: edition.language || null,
    format: edition.format || null,
    pageCount: edition.pageCount || null,
    isbn10: edition.isbn10 || null,
    isbn13: edition.isbn13 || null,
  };
}

function toSearchItem(book, edition) {
  return { book: toSearchBook(book), edition: toEdition(edition) };
}

function normalizeIsbn(value) {
  return typeof value === 'string' ? value.replace(/[\s-]/g, '') : '';
}

function isValidIsbn(value) {
  return /^(\d{9}[\dXx]|\d{13})$/.test(normalizeIsbn(value));
}

function matchesSearch(book, edition, query, type) {
  const needle = query.toLowerCase();
  const contains = (value) => String(value || '').toLowerCase().includes(needle);
  const matchesTitle = contains(book.title) || contains(book.subtitle) || contains(edition.title) || contains(edition.subtitle);
  const matchesAuthor = book.authors.some((author) => contains(author.name));
  const matchesPublisher = contains(edition.publisher && edition.publisher.name);
  const matchesSubject = book.subjects.some((subject) => contains(subject.name));
  const matchesIsbn = normalizeIsbn(edition.isbn10) === normalizeIsbn(query) || normalizeIsbn(edition.isbn13) === normalizeIsbn(query);

  switch (type) {
    case 'title': return matchesTitle;
    case 'author': return matchesAuthor;
    case 'publisher': return matchesPublisher;
    case 'subject': return matchesSubject;
    case 'isbn': return matchesIsbn;
    default: return matchesTitle || matchesAuthor || matchesPublisher || matchesSubject || matchesIsbn;
  }
}

// GET /api/books/search
router.get('/books/search', requireAuth, (req, res) => {
  const query = typeof req.query.q === 'string' ? req.query.q.trim() : '';
  const type = typeof req.query.type === 'string' ? req.query.type : 'all';
  const errors = {};
  if (!query) errors.q = ['q e obrigatorio.'];
  if (!SEARCH_TYPES.has(type)) errors.type = ['type e invalido.'];
  if (Object.keys(errors).length > 0) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  }
  const pagination = parsePagination(req, res);
  if (!pagination) return;

  if (query === PROVIDER_UNAVAILABLE_QUERY) {
    return sendError(req, res, 503, 'catalog.provider_unavailable', 'O catalogo esta temporariamente indisponivel.');
  }

  const matchedItems = state.catalogBooks.flatMap((book) =>
    book.editions
      .filter((edition) => matchesSearch(book, edition, query, type))
      .map((edition) => toSearchItem(book, edition)),
  );
  const start = (pagination.page - 1) * pagination.limit;
  const items = matchedItems.slice(start, start + pagination.limit);
  return res.status(200).json({
    items,
    page: pagination.page,
    limit: pagination.limit,
    hasNextPage: start + items.length < matchedItems.length,
  });
});

// GET /api/books/isbn/:isbn deve vir antes de /api/books/:bookId.
router.get('/books/isbn/:isbn', requireAuth, (req, res) => {
  const { isbn } = req.params;
  if (!isValidIsbn(isbn)) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', {
      isbn: ['ISBN invalido.'],
    });
  }
  if (isbn === PROVIDER_UNAVAILABLE_QUERY) {
    return sendError(req, res, 503, 'catalog.provider_unavailable', 'O catalogo esta temporariamente indisponivel.');
  }
  const normalizedIsbn = normalizeIsbn(isbn);
  for (const book of state.catalogBooks) {
    const edition = book.editions.find((candidate) =>
      normalizeIsbn(candidate.isbn10) === normalizedIsbn || normalizeIsbn(candidate.isbn13) === normalizedIsbn,
    );
    if (edition) return res.status(200).json(toSearchItem(book, edition));
  }
  return sendError(req, res, 404, 'catalog.isbn_not_found', 'Nenhuma edicao encontrada para este ISBN.');
});

// GET /api/books/:bookId
router.get('/books/:bookId', requireAuth, (req, res) => {
  const { bookId } = req.params;
  if (!isNonEmptyString(bookId)) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', {
      bookId: ['bookId e obrigatorio.'],
    });
  }
  const book = state.catalogBooks.find((candidate) => candidate.id === bookId);
  if (!book) {
    return sendError(req, res, 404, 'catalog.book_not_found', 'Livro nao encontrado.');
  }
  return res.status(200).json({
    book: {
      ...toSearchBook(book),
      description: book.description || null,
      originalTitle: book.originalTitle || null,
      subjects: book.subjects,
    },
    editions: book.editions.map(toEdition),
  });
});

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

// POST /api/book-drafts
router.post('/book-drafts', requireAuth, (req, res) => {
  const { title, authors = [], edition = null } = req.body || {};
  const errors = {};
  if (!isNonEmptyString(title)) errors.title = ['Informe um titulo.'];
  if (!Array.isArray(authors) || authors.length === 0 || authors.some((author) => !isNonEmptyString(author))) {
    errors.authors = ['Informe ao menos um autor nao vazio.'];
  }
  if (edition !== null && (typeof edition !== 'object' || Array.isArray(edition))) {
    errors.edition = ['edition deve ser um objeto ou null.'];
  }
  if (Object.keys(errors).length > 0) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  }
  const draft = {
    id: crypto.randomUUID(),
    userId: req.currentUserId,
    title: title.trim(),
    authors: authors.map((author) => author.trim()),
    edition,
    createdAt: new Date().toISOString(),
  };
  state.bookDrafts.push(draft);
  return res.status(201).json(toDraft(draft));
});

// Leitura de draft necessaria para resolver um alvo local sem duplicar seus
// dados em Bookshelf. O contrato foi formalizado junto deste mock.
router.get('/book-drafts/:userBookDraftId', requireAuth, (req, res) => {
  const draft = state.bookDrafts.find(
    (candidate) => candidate.id === req.params.userBookDraftId && candidate.userId === req.currentUserId,
  );
  if (!draft) {
    return sendError(req, res, 404, 'book_draft.not_found', 'Cadastro local nao encontrado.');
  }
  return res.status(200).json(toDraft(draft));
});

module.exports = router;
