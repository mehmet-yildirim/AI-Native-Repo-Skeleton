# Database Change Management Workflow

This document covers the full lifecycle of database schema and data changes — from planning a change through production deployment and validation.

For executing a specific migration, see the `/migrate` command.
For scaffolding, seeding, drift detection, and audit, see the `/db` command.

---

## Change Classification

Before writing any SQL, classify the change:

| Type | Definition | Risk | Deploy Order |
|---|---|---|---|
| **Additive DDL** | New table, nullable column, new index | Low | Schema before code |
| **Non-null DDL** | Non-nullable column, new constraint | Medium | Expand-Contract required |
| **Destructive DDL** | DROP table/column, RENAME | High | Code before schema |
| **DML backfill** | Populate a new column from existing data | Medium | After additive DDL |
| **DML reference** | Insert/update lookup table data | Low | After schema is stable |
| **DML transform** | Restructure or normalize existing data | High | Separate deploy, after code |

---

## Full Lifecycle

```
1. Plan           Classify change. Identify risk. Choose Expand-Contract if needed.
       │
       ▼
2. Design         Write target schema. Document rationale. Estimate table sizes.
       │
       ▼
3. Create files   Use /db create <name> or /db dml <name> to scaffold migration files.
       │
       ▼
4. Audit          Run /db audit on new files. Fix HIGH/MEDIUM issues before proceeding.
       │
       ▼
5. Test locally   Apply to local DB. Run application tests. Verify rollback works.
       │
       ▼
6. Code review    Migration files require a separate code review from the application code.
       │
       ▼
7. Staging        Apply to staging. Verify /db status shows no pending. Run smoke tests.
       │
       ▼
8. Production     Apply per the production checklist below. Monitor for 30 minutes.
       │
       ▼
9. Verify         Run /db diff to confirm no schema drift. Close the change ticket.
```

---

## Expand-Contract Pattern (Zero-Downtime)

Required for any change that would break existing running code if deployed atomically.

### Phase 1 — Expand (PR #1: schema only)
Add the new structure *alongside* the old. Old code continues to work unmodified.

```sql
-- Expand: add new column (nullable — old code ignores it)
ALTER TABLE orders ADD COLUMN payment_status_v2 VARCHAR(20);
```

Deploy: schema first → then deploy code that writes to BOTH columns.

### Phase 2 — Migrate (PR #2: data backfill)
Backfill the new structure from the old. Run as a separate DML migration.

```sql
-- Backfill in batches (see /db dml for the full template)
UPDATE orders SET payment_status_v2 = payment_status WHERE payment_status_v2 IS NULL;
```

Deploy: DML migration after code that writes both columns is live.

### Phase 3 — Contract (PR #3: remove old structure)
Remove the old column once all code uses only the new one.

```sql
-- Contract: safe because no code references payment_status anymore
ALTER TABLE orders DROP COLUMN payment_status;
ALTER TABLE orders ALTER COLUMN payment_status_v2 SET NOT NULL;
ALTER TABLE orders RENAME COLUMN payment_status_v2 TO payment_status;
```

Deploy: code removal PR merged and deployed first → then this schema change.

**Never combine Phase 1 and Phase 3 in the same deploy.**

---

## Production Deployment Checklist

### Pre-deployment (at least 1 day before)
- [ ] Migration files reviewed and approved by at least one engineer
- [ ] `/db audit` passed (no HIGH issues)
- [ ] Migration applied to staging and smoke-tested
- [ ] Row count estimated for affected tables
- [ ] For tables > 1M rows: `CREATE INDEX CONCURRENTLY`, batch DML confirmed
- [ ] Rollback procedure documented (new corrective migration or `DOWN` script)
- [ ] DBA review completed for HIGH-risk changes
- [ ] Maintenance window scheduled if downtime is expected

### Deployment sequence
```
For additive DDL (no downtime):
  1. Apply migration (flyway migrate / alembic upgrade head / prisma migrate deploy)
  2. Deploy application code
  3. Verify: /db status shows no pending migrations
  4. Verify: application health endpoint responds 200
  5. Monitor error rate for 30 minutes

For destructive DDL (may require downtime):
  1. Deploy application code that no longer uses the old column/table
  2. Wait for all running pods/workers to restart (zero instances using old code)
  3. Apply migration
  4. Verify: /db diff shows no drift
  5. Monitor error rate for 30 minutes
```

### Post-deployment
- [ ] `/db status` — no pending migrations
- [ ] `/db diff` — no schema drift detected
- [ ] Application error rate stable vs. baseline
- [ ] Key query performance verified (check EXPLAIN ANALYZE on affected queries)
- [ ] Migration recorded in change log (date, version, author, ticket)

---

## Rollback Decision Tree

```
Is the migration already applied to production?
│
├── NO → Run the DOWN migration or restore from snapshot
│
└── YES → Write a new FORWARD migration that reverses the change
           │
           ├── Is the change additive (new table/column)?
           │   └── DROP the table/column (safe if no data was written yet)
           │
           ├── Was data written to the new column/table?
           │   └── Assess data loss risk before dropping
           │       ├── Acceptable → DROP with a backup first
           │       └── Not acceptable → Leave the column, revert application code
           │
           └── Was a column/table dropped?
               └── Cannot recover from migration alone
                   └── Restore from snapshot OR recreate and re-backfill from backups
```

---

## Migration File Standards

### Naming
```
V{timestamp}__{description}.sql       # Flyway
{timestamp}_{description}.sql         # Goose, Atlas
{seq}_{description}.sql               # golang-migrate (with .up.sql/.down.sql pair)
{seq}.sqm                             # SQLDelight
```

### Required header comment
```sql
-- Migration: {description}
-- Author:    {name}
-- Date:      {YYYY-MM-DD}
-- Ticket:    {JIRA/Linear/GitHub issue URL}
-- Risk:      Low | Medium | High
-- Estimated rows affected: {N}
-- Rollback:  {procedure or "New corrective migration V{N+1}__revert_..."}
```

### Structural requirements
- Every migration must be idempotent where possible (`IF NOT EXISTS`, `IF EXISTS`, `ON CONFLICT`)
- Every migration must include a verification query: `-- Verify: SELECT COUNT(*) FROM ...`
- DML migrations must be batched for tables > 100,000 rows
- `CREATE INDEX` on tables > 10,000 rows must use `CONCURRENTLY`
- No `TRUNCATE` without explicit DBA approval and a backup step

---

## CI/CD Integration

```yaml
# .github/workflows/ci.yml
jobs:
  database:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env: { POSTGRES_DB: testdb, POSTGRES_PASSWORD: secret }
        options: --health-cmd "pg_isready -U postgres" --health-interval 5s

    steps:
      - uses: actions/checkout@v4

      - name: Apply migrations
        run: |
          # Replace with your tool's apply command:
          # Flyway:         flyway -url=$DATABASE_URL migrate
          # Alembic:        alembic upgrade head
          # Prisma:         prisma migrate deploy
          # Goose:          goose -dir ./db/migrations postgres "$DATABASE_URL" up
          # golang-migrate: migrate -path ./db/migrations -database "$DATABASE_URL" up
          # EF Core:        ./efbundle --connection "$DATABASE_URL"
          echo "TODO: add your migration command here"
        env:
          DATABASE_URL: postgres://postgres:secret@localhost/testdb

      - name: Assert no pending migrations
        run: |
          # The command below should output nothing or "No pending migrations"
          # Replace with your tool's status command
          echo "TODO: add migration status check"

      - name: Run tests against migrated DB
        run: echo "TODO: your test command"
        env:
          DATABASE_URL: postgres://postgres:secret@localhost/testdb
```

---

## Seed Data Workflow

Seed data is separate from migrations. It is applied on top of an initialized schema.

```
db/seeds/
├── reference/     → Always applied in CI and production (idempotent)
│   ├── subscription_plans.sql
│   └── country_codes.sql
├── development/   → Applied in local/dev environments only
│   └── sample_orders.sql
└── test/          → Applied before automated tests (reset between test runs)
    └── test_fixtures.sql
```

### Applying seeds
```bash
# PostgreSQL (all tools)
psql "$DATABASE_URL" -f db/seeds/reference/subscription_plans.sql

# Django
python manage.py loaddata reference_data

# Prisma
npx ts-node db/seeds/reference/seed.ts

# EF Core
dotnet run --project src/Seeder
```

### Rules
- Reference seeds: idempotent (`ON CONFLICT ... DO NOTHING` or `DO UPDATE`)
- Development/test seeds: reset-safe (DELETE all rows before inserting, or use transactions)
- Never apply development seeds to production
- Commit seed files alongside the migration that creates the seeded table

---

## Schema Drift Response

If `/db diff` detects drift:

| Finding | Likely cause | Action |
|---|---|---|
| Table in DB not in migrations | Manual table created in prod | Create migration to drop it, or add it to migrations |
| Column in DB not in migrations | Manual column added in prod | Add to migrations or document as technical debt |
| Index missing in DB | Migration failed silently | Re-apply the specific migration or create a fix migration |
| Table in migrations not in DB | Migration never applied | Apply pending migrations immediately |
| Constraint mismatch | Manual ALTER in prod | Create corrective migration |

**Never manually modify production schema** — all changes must go through migrations. If an emergency manual change was made, immediately create a migration that documents it.

---

## Tool Quick Reference

| Operation | Flyway | Alembic | Prisma | Goose | EF Core |
|---|---|---|---|---|---|
| Apply all | `flyway migrate` | `alembic upgrade head` | `prisma migrate deploy` | `goose up` | `ef database update` |
| Status | `flyway info` | `alembic current` | `prisma migrate status` | `goose status` | `ef migrations list` |
| New migration | `V{N}__name.sql` | `alembic revision -m` | `prisma migrate dev` | `goose create name sql` | `ef migrations add` |
| Rollback | `flyway undo` (Teams) | `alembic downgrade -1` | manual | `goose down` | `ef database update PrevMigration` |
| Diff / validate | `flyway validate` | `alembic check` | `prisma migrate diff` | — | `ef migrations has-pending-model-changes` |
