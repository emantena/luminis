const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function isValidEmail(value) {
  return isNonEmptyString(value) && EMAIL_PATTERN.test(value.trim());
}

module.exports = { isNonEmptyString, isValidEmail };
