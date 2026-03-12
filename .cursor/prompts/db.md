Database change management operations — initialization, migration scaffolding, DML changes, seed data, schema drift detection, and audit.

This prompt complements `@.cursor/prompts/migrate.md` (which plans and executes a specific migration).
Use this prompt for lifecycle management: setting up tooling, scaffolding files, checking state, managing seeds.

---

## Subcommands

| Subcommand | What it does |
|---|---|
| `db init` | Bootstrap migration infrastructure for the detected stack |
| `db create <name>` | Scaffold a new DDL migration file with proper naming and sequencing |
| `db dml <name>` | Scaffold a DML data migration (backfill, reference data, data transform) |
| `db seed <env>` | Generate or apply seed data for the specified environment |
| `db status` | Show pending migrations and current schema version |
| `db diff` | Detect schema drift between expected (migrations) and actual (database) |
| `db audit` | Review recent migration files for safety issues before deployment |

---

## Step 1: Detect Context

Reference `@CLAUDE.md` and scan the project for migration tool signals:
- `flyway.conf` or `db/migration/V*.sql` → Flyway
- `alembic.ini` or `alembic/` → Alembic
- `manage.py` + `*/migrations/*.py` → Django Migrations
- `prisma/schema.prisma` → Prisma Migrate
- `drizzle.config.*` → Drizzle
- `db/migrations/*.sql` with `-- +goose` markers → Goose
- `db/migrations/*.[0-9]*.up.sql` → golang-migrate
- `atlas.hcl` → Atlas
- `Migrations/*.cs` → EF Core
- `@Database(version=...)` → Room
- `MigrationStrategy` in `*.dart` → drift
- `*.sqm` files → SQLDelight

---

## `db init`

Set up migration tooling for a project that doesn't have it yet. Produce:
1. The exact setup commands for the detected stack
2. The directory structure that will be created
3. Any required config file snippets (with placeholders for credentials)
4. CI/CD step to add for running migrations on every deploy
5. Checklist of what to configure before running the first migration

---

## `db create <name>`

Scaffold the next numbered DDL migration file:
1. Determine the next version/filename based on detected tool and existing files
2. Generate a scaffolded file with:
   - Header comment (description + ticket ID placeholder)
   - `Up` section with ALTER TABLE skeleton for the description
   - `Down` / rollback section (even if the tool is forward-only, document it)
   - `-- TODO: check lock impact on large tables` reminder
3. Report the created path and the next step

---

## `db dml <name>`

Scaffold a DML data migration. Based on the description, generate one of:

**Backfill** — populate a new column from existing data:
```sql
-- Idempotent batch backfill
DO $$ DECLARE batch INT := 1000; n INT; BEGIN
  LOOP
    UPDATE {table} SET {col} = {expr} WHERE id IN (
      SELECT id FROM {table} WHERE {col} IS NULL LIMIT batch);
    GET DIAGNOSTICS n = ROW_COUNT;
    EXIT WHEN n = 0;
    PERFORM pg_sleep(0.1);
  END LOOP;
END $$;
```

**Reference data** — idempotent insert/update:
```sql
INSERT INTO {table} ({cols}) VALUES ... ON CONFLICT ({pk}) DO NOTHING;
```

**Data transform** — with pre-condition verification:
```sql
BEGIN;
  DO $$ BEGIN
    IF EXISTS(SELECT 1 FROM {table} WHERE {unexpected}) THEN
      RAISE EXCEPTION 'Unexpected data — review before proceeding';
    END IF;
  END $$;
  UPDATE {table} SET {new_col} = {transform}({old_col});
COMMIT;
```

Include: "how to verify success" query, estimated row count, and note on whether it's safe to re-run.

---

## `db seed <env>`

Generate a seed script for the specified environment:
- `reference` — lookup tables, enums, config; all environments; `ON CONFLICT DO UPDATE`
- `development` — realistic fake data; dev/staging only; `ON CONFLICT DO NOTHING`
- `test` — minimal deterministic data; `ON CONFLICT DO NOTHING`

Place in `db/seeds/{env}/` and report how to run it for the detected tool.

---

## `db status`

Report migration state using the appropriate command for the detected tool, then format output as:
```
Applied:  ✅ V1 (date), ✅ V2 (date)
Pending:  ⏳ V3 (not applied)
Version:  V2 → V3 available
```
Warn on: failed migrations, out-of-order states, checksum mismatches.

---

## `db diff`

Detect schema drift:
1. Apply all migrations to a fresh DB (or use Atlas/pg_dump)
2. Diff against the target DB schema
3. Report tables/columns/indexes that exist in one but not the other
4. Recommend corrective actions (new migration, manual cleanup, or update migration files)

---

## `db audit`

Review pending/recent migration files and flag:

**Block deployment (HIGH):**
- `DROP TABLE/COLUMN` without prior code removal
- `ADD COLUMN NOT NULL` without default (table lock)
- Unbatched `UPDATE` on large tables
- `TRUNCATE` (data loss)
- `RENAME` (breaks ORM references)

**Review required (MEDIUM):**
- `CREATE INDEX` without `CONCURRENTLY`
- Missing rollback migration
- Combined DDL + DML in one migration
- Non-idempotent DML

**Verdict:** PASS / REVIEW / BLOCK with specific line references.

---

## After Each Subcommand

1. Show the generated file(s) or command output
2. State the next action:
   - `db create` / `db dml`: fill in TODOs → use `@.cursor/prompts/migrate.md` to plan execution
   - `db status` / `db diff`: list corrective actions
   - `db audit`: list issues with fixes

---

**Operation** (`<subcommand> [name/env]` — e.g., `create add_user_preferences`, `dml backfill_order_totals`, `seed reference`, `status`, `diff`, `audit`):
