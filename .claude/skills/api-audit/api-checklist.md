# API Audit Checklist

## Per Endpoint

### Auth & Authorization
- [ ] Protected endpoints use `current_user` dependency
- [ ] Ownership checks: user can only access their own resources
- [ ] Role-based access enforced where needed
- [ ] No endpoint returns 200 on unauthorized access

### Request Validation
- [ ] Request body uses a typed Pydantic schema
- [ ] All required fields are marked required
- [ ] String fields have `max_length` constraints
- [ ] Enum fields use Python `Enum` or `Literal` types
- [ ] `extra="forbid"` on request schemas (no unexpected fields accepted)

### Response
- [ ] Response uses a typed Pydantic schema (not raw dict)
- [ ] No internal fields exposed (hashed passwords, internal IDs, tokens)
- [ ] Status code is correct: 200, 201, 204, 400, 401, 403, 404, 409, 422, 500
- [ ] Collection endpoints return paginated response: `{ items, total, page, size }`
- [ ] Error responses have consistent shape: `{ detail: string }`

### Performance
- [ ] No N+1 queries (check for missing `selectinload` / `joinedload`)
- [ ] Filtered fields have DB indexes
- [ ] Large collections never return unbounded results

### Code Structure
- [ ] Handler is thin (≤ 15 lines)
- [ ] Business logic lives in service, not handler
- [ ] DB access goes through repository, not service
- [ ] No hardcoded strings — use constants or enums

### Tests
- [ ] Happy path test exists
- [ ] 401/403 test exists
- [ ] 404 test exists
- [ ] Validation failure (422) test exists
