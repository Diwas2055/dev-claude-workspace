# Security Rules

## Secrets & Credentials
- Never read, log, or print `.env`, `.env.*`, or any secrets file
- Never hardcode secrets, tokens, or passwords in source code
- All secrets must come from environment variables via `app/core/config.py`
- Never commit `.env` files — `.gitignore` must cover all variants

## Authentication & Authorization
- All protected endpoints must use the `current_user` dependency
- Never bypass auth with a comment like "TODO: add auth later"
- JWTs must have explicit expiry — never issue non-expiring tokens
- Refresh tokens must be stored hashed, not plaintext
- Always verify token audience and issuer claims

## Input Validation
- Validate and sanitize all user inputs at the Pydantic schema layer
- Never use user input directly in file paths, shell commands, or SQL strings
- Limit string field lengths — unbounded strings are a DoS risk
- Reject unexpected fields using `model_config = ConfigDict(extra="forbid")`

## Data Exposure
- Never return password hashes, tokens, or internal IDs in API responses
- Use separate response schemas — never expose ORM model fields directly
- Apply field-level filtering based on user role when returning sensitive data

## Dependencies
- Run `pip audit` or `uv audit` before each release
- Never install packages from untrusted sources
- Pin all dependency versions in `requirements.txt` or `pyproject.toml`

## Logging
- Never log request bodies that may contain passwords or PII
- Redact sensitive fields before logging: mask tokens, emails, phone numbers
- Use structured logging (JSON) — never concatenate user data into log strings
