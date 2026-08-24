const crypto = require('crypto');
const express = require('express');

const state = require('../state');
const { sendError } = require('../errors');
const { isNonEmptyString, isValidEmail, isValidHttpUrl } = require('../validators');
const { requireAuth } = require('../authMiddleware');

const router = express.Router();

const ACCESS_TOKEN_TTL_MS = 60 * 60 * 1000; // 1h, apenas para o mock local.
const MAX_FAILED_ATTEMPTS = 5;
const LOCKOUT_DURATION_MS = 15 * 60 * 1000; // 15min, apenas para o mock local.

function issueSession(userId) {
  const accessToken = `mock-access-${crypto.randomUUID()}`;
  const refreshToken = `mock-refresh-${crypto.randomUUID()}`;
  const expiresAt = new Date(Date.now() + ACCESS_TOKEN_TTL_MS);

  state.accessTokens.set(accessToken, { userId, expiresAt: expiresAt.getTime() });
  state.refreshTokens.set(refreshToken, { userId, revoked: false });

  return { accessToken, refreshToken, expiresAt };
}

function toAuthUser(user) {
  return {
    id: user.id,
    displayName: user.displayName,
    photoUrl: user.photoUrl,
    status: user.status,
  };
}

function toMeResponse(user) {
  return {
    id: user.id,
    displayName: user.displayName,
    photoUrl: user.photoUrl,
    bio: user.bio,
    status: user.status,
  };
}

function findCredentialByEmail(email) {
  const normalized = email.trim().toLowerCase();
  return state.passwordCredentials.find((c) => c.email.toLowerCase() === normalized);
}

// POST /api/auth/register
router.post('/auth/register', (req, res) => {
  const { displayName, email, password } = req.body || {};

  const errors = {};
  if (!isNonEmptyString(displayName)) {
    errors.displayName = ['Nome de exibicao e obrigatorio.'];
  }
  if (!isValidEmail(email)) {
    errors.email = ['Informe um email valido.'];
  }
  if (!isNonEmptyString(password) || password.trim().length < 8) {
    errors.password = ['Senha deve ter ao menos 8 caracteres.'];
  }
  if (Object.keys(errors).length > 0) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  }

  if (findCredentialByEmail(email)) {
    return sendError(req, res, 409, 'auth.email_already_used', 'Este email ja esta em uso.');
  }

  const user = {
    id: crypto.randomUUID(),
    displayName: displayName.trim(),
    photoUrl: null,
    bio: null,
    status: 'active',
    createdAt: new Date().toISOString(),
  };
  state.users.push(user);
  state.passwordCredentials.push({
    userId: user.id,
    email: email.trim().toLowerCase(),
    password,
    failedAttempts: 0,
    lockedUntil: null,
    lastLoginAt: null,
  });

  const session = issueSession(user.id);
  return res.status(201).json({
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
    expiresAt: session.expiresAt.toISOString(),
    user: toAuthUser(user),
  });
});

// POST /api/auth/login
router.post('/auth/login', (req, res) => {
  const { email, password } = req.body || {};

  const errors = {};
  if (!isValidEmail(email)) {
    errors.email = ['Informe um email valido.'];
  }
  if (!isNonEmptyString(password)) {
    errors.password = ['Senha e obrigatoria.'];
  }
  if (Object.keys(errors).length > 0) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  }

  const credential = findCredentialByEmail(email);
  if (!credential) {
    return sendError(req, res, 401, 'auth.invalid_credentials', 'Email ou senha invalidos.');
  }

  if (credential.lockedUntil && new Date(credential.lockedUntil).getTime() > Date.now()) {
    return sendError(
      req,
      res,
      401,
      'auth.account_locked',
      'Conta temporariamente bloqueada por excesso de tentativas invalidas.',
    );
  }

  if (credential.password !== password) {
    credential.failedAttempts += 1;
    if (credential.failedAttempts >= MAX_FAILED_ATTEMPTS) {
      credential.lockedUntil = new Date(Date.now() + LOCKOUT_DURATION_MS).toISOString();
    }
    return sendError(req, res, 401, 'auth.invalid_credentials', 'Email ou senha invalidos.');
  }

  credential.failedAttempts = 0;
  credential.lockedUntil = null;
  credential.lastLoginAt = new Date().toISOString();

  const user = state.users.find((u) => u.id === credential.userId);
  const session = issueSession(user.id);
  return res.status(200).json({
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
    expiresAt: session.expiresAt.toISOString(),
    user: toAuthUser(user),
  });
});

// POST /api/auth/google
router.post('/auth/google', (req, res) => {
  const { idToken } = req.body || {};

  if (!isNonEmptyString(idToken)) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', {
      idToken: ['idToken e obrigatorio.'],
    });
  }

  const googleProfile = state.googleTokens.find((t) => t.idToken === idToken);
  if (!googleProfile) {
    return sendError(req, res, 401, 'auth.google_token_invalid', 'Token do Google invalido ou expirado.');
  }

  let externalLogin = state.externalLogins.find(
    (l) => l.provider === 'google' && l.providerUserId === googleProfile.providerUserId,
  );

  let user;
  if (externalLogin) {
    user = state.users.find((u) => u.id === externalLogin.userId);
  } else {
    let linkedUserId = null;

    // So vincula automaticamente a uma credencial local quando o Google
    // reporta o email como verificado (regra documentada em
    // docs/architecture/backend-contracts.md).
    if (googleProfile.verifiedEmail) {
      const credential = findCredentialByEmail(googleProfile.providerEmail);
      if (credential) {
        linkedUserId = credential.userId;
      }
    }

    if (!linkedUserId) {
      user = {
        id: crypto.randomUUID(),
        displayName: googleProfile.displayName,
        photoUrl: googleProfile.photoUrl || null,
        bio: null,
        status: 'active',
        createdAt: new Date().toISOString(),
      };
      state.users.push(user);
      linkedUserId = user.id;
    } else {
      user = state.users.find((u) => u.id === linkedUserId);
    }

    externalLogin = {
      userId: linkedUserId,
      provider: 'google',
      providerUserId: googleProfile.providerUserId,
      providerEmail: googleProfile.providerEmail,
      createdAt: new Date().toISOString(),
      lastLoginAt: null,
    };
    state.externalLogins.push(externalLogin);
  }

  externalLogin.lastLoginAt = new Date().toISOString();

  const session = issueSession(user.id);
  return res.status(200).json({
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
    expiresAt: session.expiresAt.toISOString(),
    user: toAuthUser(user),
  });
});

// POST /api/auth/logout
router.post('/auth/logout', requireAuth, (req, res) => {
  const { refreshToken } = req.body || {};

  if (!isNonEmptyString(refreshToken)) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', {
      refreshToken: ['refreshToken e obrigatorio.'],
    });
  }

  const session = state.refreshTokens.get(refreshToken);
  if (session) {
    session.revoked = true;
  }

  return res.status(200).json({ success: true });
});

// POST /api/auth/forgot-password
router.post('/auth/forgot-password', (req, res) => {
  const { email } = req.body || {};

  if (!isValidEmail(email)) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', {
      email: ['Informe um email valido.'],
    });
  }

  // Regra do contrato (docs/architecture/backend-contracts.md): nao revelar
  // se o email existe. So gera token quando a credencial existir; a resposta
  // e identica nos dois casos.
  const credential = findCredentialByEmail(email);
  if (credential) {
    const token = `mock-reset-${crypto.randomUUID()}`;
    state.passwordResetTokens.set(token, {
      userId: credential.userId,
      createdAt: new Date().toISOString(),
      usedAt: null,
    });
  }

  return res.status(200).json({ success: true });
});

// POST /api/auth/reset-password
router.post('/auth/reset-password', (req, res) => {
  const { token, newPassword } = req.body || {};

  const errors = {};
  if (!isNonEmptyString(token)) {
    errors.token = ['token e obrigatorio.'];
  }
  if (!isNonEmptyString(newPassword) || newPassword.trim().length < 8) {
    errors.newPassword = ['Senha deve ter ao menos 8 caracteres.'];
  }
  if (Object.keys(errors).length > 0) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  }

  const reset = state.passwordResetTokens.get(token);
  if (!reset || reset.usedAt) {
    return sendError(req, res, 401, 'auth.password_reset_token_invalid', 'Token de recuperacao invalido ou expirado.');
  }

  const credential = state.passwordCredentials.find((c) => c.userId === reset.userId);
  if (credential) {
    credential.password = newPassword;
    credential.failedAttempts = 0;
    credential.lockedUntil = null;
  }
  reset.usedAt = new Date().toISOString();

  return res.status(200).json({ success: true });
});

// GET /api/me
router.get('/me', requireAuth, (req, res) => {
  const user = state.users.find((u) => u.id === req.currentUserId);
  if (!user) {
    return sendError(req, res, 401, 'auth.unauthorized', 'Sessao invalida ou expirada.');
  }

  return res.status(200).json(toMeResponse(user));
});

// PATCH /api/me
router.patch('/me', requireAuth, (req, res) => {
  const user = state.users.find((u) => u.id === req.currentUserId);
  if (!user) {
    return sendError(req, res, 401, 'auth.unauthorized', 'Sessao invalida ou expirada.');
  }

  const { displayName, photoUrl, bio } = req.body || {};
  const errors = {};

  if (!isNonEmptyString(displayName)) {
    errors.displayName = ['Nome de exibicao e obrigatorio.'];
  } else if (displayName.trim().length > 120) {
    errors.displayName = ['Nome de exibicao deve ter no maximo 120 caracteres.'];
  }

  if (bio !== undefined && bio !== null && typeof bio !== 'string') {
    errors.bio = ['Bio deve ser texto ou null.'];
  } else if (typeof bio === 'string' && bio.length > 500) {
    errors.bio = ['Bio deve ter no maximo 500 caracteres.'];
  }

  if (photoUrl !== undefined && photoUrl !== null && typeof photoUrl !== 'string') {
    errors.photoUrl = ['Foto deve ser uma URL ou null.'];
  } else if (typeof photoUrl === 'string' && !isValidHttpUrl(photoUrl)) {
    errors.photoUrl = ['Foto deve ser uma URL absoluta http ou https.'];
  }

  if (Object.keys(errors).length > 0) {
    return sendError(req, res, 400, 'validation.failed', 'Existem campos invalidos.', errors);
  }

  user.displayName = displayName.trim();
  user.photoUrl = photoUrl === undefined ? user.photoUrl : photoUrl === null ? null : photoUrl.trim();
  user.bio = bio === undefined ? user.bio : bio === null ? null : bio.trim();

  return res.status(200).json(toMeResponse(user));
});

module.exports = router;
