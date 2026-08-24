const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function isValidEmail(value) {
  return isNonEmptyString(value) && EMAIL_PATTERN.test(value.trim());
}

function isValidHttpUrl(value) {
  if (!isNonEmptyString(value)) return false;
  try {
    const url = new URL(value.trim());
    return url.protocol === 'http:' || url.protocol === 'https:';
  } catch {
    return false;
  }
}

module.exports = { isNonEmptyString, isValidEmail, isValidHttpUrl };
