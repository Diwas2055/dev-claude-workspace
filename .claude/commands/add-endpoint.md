# add-endpoint

Scaffold a new API endpoint following project conventions.

## Steps

1. **Schema** (`app/schemas/<resource>.py`)
   - `<Resource>Create` — request body
   - `<Resource>Response` — response body
   - `<Resource>Update` — partial update (all fields Optional)

2. **Model** (`app/models/<resource>.py`)
   - SQLAlchemy async model
   - Include `id`, `created_at`, `updated_at` on every model
   - Add `__tablename__` explicitly

3. **Repository** (`app/repositories/<resource>.py`)
   - `get_by_id`, `get_all` (paginated), `create`, `update`, `delete`
   - Typed return annotations on all methods

4. **Service** (`app/services/<resource>.py`)
   - Business logic only — no direct DB access, no HTTP knowledge
   - Raise domain exceptions here (e.g., `ResourceNotFound`, `Conflict`)

5. **Router** (`app/api/v1/<resource>.py`)
   - Thin handlers: validate → call service → return schema
   - Register with `app/api/v1/__init__.py`

6. **Migration**
   - `alembic revision --autogenerate -m "add_<resource>_table"`
   - Review the generated file before applying

7. **Tests** (`tests/api/test_<resource>.py`)
   - Use the `write-tests` command to generate full coverage

## Checklist
- [ ] Schemas created and validated
- [ ] Model created with migration
- [ ] Repository layer complete
- [ ] Service layer complete
- [ ] Router registered
- [ ] Tests written and passing
- [ ] `ruff check . && ruff format .` clean
