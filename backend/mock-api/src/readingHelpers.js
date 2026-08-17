const crypto = require('crypto');

const state = require('./state');

const ACTIVE_SESSION_STATUSES = new Set(['active', 'paused']);

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

function dateOnlyFromIso(value) {
  return String(value).slice(0, 10);
}

function findBook(bookId) {
  return state.catalogBooks.find((book) => book.id === bookId);
}

function findEdition(item) {
  if (!item || item.target.type !== 'book') return null;
  const book = findBook(item.target.bookId);
  return book && book.editions.find((candidate) => candidate.id === item.target.editionId);
}

function findDraft(item) {
  if (!item || item.target.type !== 'draft') return null;
  return state.bookDrafts.find((draft) => draft.id === item.target.userBookDraftId && draft.userId === item.userId);
}

function itemTitle(item) {
  if (item.target.type === 'book') {
    return findBook(item.target.bookId)?.title || 'Livro da estante';
  }
  return findDraft(item)?.title || 'Livro da estante';
}

function itemPageCount(item) {
  if (item.target.type === 'book') return findEdition(item)?.pageCount || null;
  return findDraft(item)?.edition?.pageCount || null;
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

function toBookshelfItemResponse(item) {
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
  const draft = findDraft(item);
  return { ...base, book: null, edition: null, draft: draft ? toDraft(draft) : null };
}

function activePlanFor(bookshelfItemId) {
  return state.readingPlans.find((plan) => plan.bookshelfItemId === bookshelfItemId && plan.status === 'active') || null;
}

function relevantSessionFor(bookshelfItemId) {
  const matches = state.readingSessions
    .filter((session) => session.bookshelfItemId === bookshelfItemId && ACTIVE_SESSION_STATUSES.has(session.status))
    .sort((a, b) => Date.parse(b.startedAt) - Date.parse(a.startedAt));
  return matches[0] || null;
}

function latestProgressForSession(readingSessionId) {
  const matches = state.readingProgressEntries
    .filter((entry) => entry.readingSessionId === readingSessionId)
    .sort((a, b) => Date.parse(b.createdAt) - Date.parse(a.createdAt));
  return matches[0] || null;
}

function createSessionForItem(item, status = null) {
  const sessionStatus = status || (item.readingStatus === 'paused' ? 'paused' : 'active');
  const session = {
    id: crypto.randomUUID(),
    bookshelfItemId: item.id,
    status: sessionStatus,
    startedAt: item.startedAt || nowIso(),
    finishedAt: null,
  };
  state.readingSessions.push(session);
  return session;
}

function ensureSessionForItem(item) {
  const existing = relevantSessionFor(item.id);
  if (existing) return existing;
  if (item.readingStatus === 'reading' || item.readingStatus === 'rereading') return createSessionForItem(item, 'active');
  if (item.readingStatus === 'paused') return createSessionForItem(item, 'paused');
  return null;
}

function finishSession(session, status) {
  session.status = status;
  session.finishedAt = nowIso();
}

function cancelActivePlan(bookshelfItemId) {
  const plan = activePlanFor(bookshelfItemId);
  if (!plan) return;
  plan.status = 'cancelled';
  plan.updatedAt = nowIso();
}

function completeActivePlan(bookshelfItemId) {
  const plan = activePlanFor(bookshelfItemId);
  if (!plan) return;
  plan.status = 'completed';
  plan.updatedAt = nowIso();
}

function ensureFinalProgress(session, item) {
  const pageCount = itemPageCount(item);
  if (!pageCount) return;
  const last = latestProgressForSession(session.id);
  if (last?.pageNumber === pageCount) return;
  state.readingProgressEntries.push({
    id: crypto.randomUUID(),
    readingSessionId: session.id,
    pageNumber: pageCount,
    percentage: 100,
    note: null,
    isPublic: false,
    createdAt: nowIso(),
  });
}

function applyReadingStatus(item, readingStatus, sessionAction = null) {
  const now = nowIso();
  const session = relevantSessionFor(item.id);

  if (readingStatus === 'want_to_read' && session && !sessionAction) {
    return { error: { field: 'sessionAction', message: 'Informe como tratar a sessao atual.' } };
  }

  item.readingStatus = readingStatus;
  item.updatedAt = now;

  if (readingStatus === 'reading' || readingStatus === 'rereading') {
    item.finishedAt = null;
    if (!item.startedAt) item.startedAt = now;
    if (session) {
      session.status = 'active';
      session.finishedAt = null;
    } else {
      createSessionForItem(item, 'active');
    }
  }

  if (readingStatus === 'paused') {
    if (session) session.status = 'paused';
    cancelActivePlan(item.id);
  }

  if (readingStatus === 'read') {
    item.finishedAt = now;
    const active = session || createSessionForItem(item, 'active');
    ensureFinalProgress(active, item);
    finishSession(active, 'finished');
    completeActivePlan(item.id);
  }

  if (readingStatus === 'abandoned') {
    item.finishedAt = now;
    if (session) finishSession(session, 'abandoned');
    cancelActivePlan(item.id);
  }

  if (readingStatus === 'want_to_read') {
    item.finishedAt = null;
    if (sessionAction === 'interrupt' && session) finishSession(session, 'interrupted');
    if (sessionAction === 'keep_paused' && session) session.status = 'paused';
    cancelActivePlan(item.id);
  }

  return { item };
}

function validateProgressPayload(item, session, body) {
  const errors = {};
  const { pageNumber, percentage, note, isPublic } = body;
  if (pageNumber === undefined && percentage === undefined) errors.progress = ['Informe pagina ou percentual.'];
  if (pageNumber !== undefined && (!Number.isInteger(pageNumber) || pageNumber <= 0)) {
    errors.pageNumber = ['A pagina deve ser maior que zero.'];
  }
  const pageCount = itemPageCount(item);
  if (pageCount && pageNumber !== undefined && pageNumber > pageCount) {
    errors.pageNumber = [`A pagina nao pode passar de ${pageCount}.`];
  }
  const lastPage = latestProgressForSession(session.id)?.pageNumber;
  if (lastPage !== undefined && pageNumber !== undefined && pageNumber < lastPage) {
    return { conflict: 'A pagina nao pode ser menor que o progresso anterior.' };
  }
  if (percentage !== undefined && (!Number.isInteger(percentage) || percentage < 0 || percentage > 100)) {
    errors.percentage = ['O percentual deve ficar entre 0 e 100.'];
  }
  if (note !== undefined && note !== null && typeof note !== 'string') errors.note = ['note deve ser texto ou null.'];
  if (isPublic !== undefined && typeof isPublic !== 'boolean') errors.isPublic = ['isPublic deve ser booleano.'];
  return { errors };
}

function registerProgress(session, body) {
  const item = state.bookshelfItems.find((candidate) => candidate.id === session.bookshelfItemId && !candidate.removedAt);
  const validation = validateProgressPayload(item, session, body);
  if (validation.conflict) return { conflict: validation.conflict };
  if (Object.keys(validation.errors).length > 0) return { errors: validation.errors };

  const entry = {
    id: crypto.randomUUID(),
    readingSessionId: session.id,
    pageNumber: body.pageNumber ?? null,
    percentage: body.percentage ?? null,
    note: typeof body.note === 'string' && body.note.trim() ? body.note.trim() : null,
    isPublic: body.isPublic === true,
    createdAt: nowIso(),
  };
  state.readingProgressEntries.push(entry);

  const pageCount = itemPageCount(item);
  const completedReading = (pageCount && body.pageNumber >= pageCount) || body.percentage === 100;
  if (completedReading) applyReadingStatus(item, 'read');

  return { entry, item, completedReading };
}

function savePlan(item, body) {
  const errors = {};
  if (!isDateOnly(body.targetFinishDate)) errors.targetFinishDate = ['targetFinishDate deve usar YYYY-MM-DD.'];
  if (body.startDate !== undefined && !isDateOnly(body.startDate)) errors.startDate = ['startDate deve usar YYYY-MM-DD.'];
  if (isDateOnly(body.targetFinishDate) && parseDateOnly(body.targetFinishDate) < parseDateOnly(todayDateOnly())) {
    errors.targetFinishDate = ['targetFinishDate nao deve ser anterior a data atual.'];
  }
  if (Object.keys(errors).length > 0) return { errors };

  const now = nowIso();
  let plan = activePlanFor(item.id);
  if (plan) {
    plan.targetFinishDate = body.targetFinishDate;
    if (body.startDate !== undefined) plan.startDate = body.startDate;
    plan.updatedAt = now;
  } else {
    plan = {
      id: crypto.randomUUID(),
      bookshelfItemId: item.id,
      status: 'active',
      startDate: body.startDate || todayDateOnly(),
      targetFinishDate: body.targetFinishDate,
      createdAt: now,
      updatedAt: now,
    };
    state.readingPlans.push(plan);
  }
  return { plan };
}

function removePlan(item) {
  cancelActivePlan(item.id);
}

function calculatePace(item, progress, plan) {
  const pageCount = itemPageCount(item);
  if (!plan || !pageCount || !progress?.pageNumber) {
    return {
      canCalculate: false,
      remainingPages: pageCount && progress?.pageNumber ? Math.max(pageCount - progress.pageNumber, 0) : null,
      remainingDays: null,
      dailyPagesTarget: null,
    };
  }
  const remainingPages = Math.max(pageCount - progress.pageNumber, 0);
  const remainingDays = Math.round((parseDateOnly(plan.targetFinishDate) - parseDateOnly(todayDateOnly())) / (24 * 60 * 60 * 1000));
  if (remainingDays <= 0) {
    return { canCalculate: false, remainingPages, remainingDays, dailyPagesTarget: null };
  }
  return {
    canCalculate: true,
    remainingPages,
    remainingDays,
    dailyPagesTarget: Math.ceil(remainingPages / remainingDays),
  };
}

function toReadingStateResponse(item) {
  const session = ensureSessionForItem(item);
  const lastProgress = session ? latestProgressForSession(session.id) : null;
  const activePlan = activePlanFor(item.id);
  return {
    bookshelfItem: toBookshelfItemResponse(item),
    session: session
      ? {
          id: session.id,
          bookshelfItemId: session.bookshelfItemId,
          status: session.status,
          startedAt: session.startedAt,
          finishedAt: session.finishedAt || null,
        }
      : null,
    lastProgress: lastProgress
      ? {
          id: lastProgress.id,
          readingSessionId: lastProgress.readingSessionId,
          pageNumber: lastProgress.pageNumber ?? null,
          percentage: lastProgress.percentage ?? null,
          note: lastProgress.note || null,
          isPublic: lastProgress.isPublic === true,
          createdAt: lastProgress.createdAt,
        }
      : null,
    activePlan: activePlan
      ? {
          id: activePlan.id,
          bookshelfItemId: activePlan.bookshelfItemId,
          startDate: activePlan.startDate,
          targetFinishDate: activePlan.targetFinishDate,
        }
      : null,
    readingPace: calculatePace(item, lastProgress, activePlan),
  };
}

function pageContributorsForGoal(goal) {
  const byTitle = new Map();
  for (const session of state.readingSessions) {
    const item = state.bookshelfItems.find((candidate) => candidate.id === session.bookshelfItemId && candidate.userId === goal.userId);
    if (!item) continue;
    const entries = state.readingProgressEntries
      .filter((entry) => entry.readingSessionId === session.id && dateOnlyFromIso(entry.createdAt) >= goal.startsOn && dateOnlyFromIso(entry.createdAt) <= goal.endsOn)
      .sort((a, b) => Date.parse(a.createdAt) - Date.parse(b.createdAt));
    let previousPage = null;
    for (const entry of entries) {
      if (!Number.isInteger(entry.pageNumber)) continue;
      const advance = previousPage == null ? entry.pageNumber : Math.max(entry.pageNumber - previousPage, 0);
      previousPage = entry.pageNumber;
      if (advance <= 0) continue;
      const title = itemTitle(item);
      byTitle.set(title, (byTitle.get(title) || 0) + advance);
    }
  }
  return [...byTitle.entries()].map(([title, value]) => ({
    title,
    value,
    description: 'Paginas novas lidas no periodo.',
  }));
}

function bookContributorsForGoal(goal) {
  const byTitle = new Map();
  for (const session of state.readingSessions) {
    if (session.status !== 'finished' || !session.finishedAt) continue;
    const finishedOn = dateOnlyFromIso(session.finishedAt);
    if (finishedOn < goal.startsOn || finishedOn > goal.endsOn) continue;
    const item = state.bookshelfItems.find((candidate) => candidate.id === session.bookshelfItemId && candidate.userId === goal.userId);
    if (!item) continue;
    const title = itemTitle(item);
    byTitle.set(title, (byTitle.get(title) || 0) + 1);
  }
  return [...byTitle.entries()].map(([title, value]) => ({
    title,
    value,
    description: value > 1 ? 'Leituras concluidas no periodo.' : 'Leitura concluida no periodo.',
  }));
}

function contributorsForGoal(goal) {
  return goal.metricType === 'pages_read' ? pageContributorsForGoal(goal) : bookContributorsForGoal(goal);
}

module.exports = {
  applyReadingStatus,
  contributorsForGoal,
  createSessionForItem,
  ensureFinalProgress,
  nowIso,
  registerProgress,
  removePlan,
  savePlan,
  toBookshelfItemResponse,
  toReadingStateResponse,
};
