# API Development Rules

## Route Handlers
- Handlers must stay thin: validate input, call service, return response
- Never put business logic directly in route files
- Every route must declare explicit request and response schemas
- Use `status_code` explicitly on every endpoint decorator
- Group routes by resource using `APIRouter` with a consistent prefix

## Request / Response
- All request bodies use Pydantic `BaseModel` with field validators
- Responses must use typed schema classes — never return raw dicts
- Use `Optional` + `None` default for all nullable fields
- Paginate all collection endpoints: return `{ items, total, page, size }`

## Error Handling
- Raise `HTTPException` with specific status codes from route layer
- Never leak internal error messages or stack traces to clients
- Use a global exception handler for unhandled errors (500 fallback)
- Log all 5xx errors with full context before returning to client

## Dependency Injection
- Use `Depends()` for: DB session, current user, settings, rate limiter
- Never instantiate services or repos directly inside handlers

## Versioning
- All routes live under `/api/v1/` prefix
- Breaking changes require a new version prefix, not in-place edits
