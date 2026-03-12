# Database Change Management Standards

## Core Rules
- Migrations are immutable — never edit an applied migration file; create a new one
- Forward-only by default — rollback = new corrective migration; scripts are fallback only
- Schema before code for additive changes; code before schema for destructive changes
- **Never** `spring.jpa.hibernate.ddl-auto=update`, `db.AutoMigrate()`, or EF `Ensure-Created` in production
- All migration files: snake_case, no spaces, include ticket ID: `0042_PROJ-123_add_user_preferences.sql`

## Tool Selection Per Stack
| Stack | Primary Tool | Alternative |
|---|---|---|
| Java / Spring Boot | Flyway | Liquibase |
| Python / SQLAlchemy | Alembic | — |
| Python / Django | Django Migrations | — |
| TypeScript / Node.js | Prisma Migrate or Drizzle | Knex, TypeORM |
| Go | Goose | golang-migrate, Atlas |
| .NET / EF Core | EF Core Migrations (bundle deploy) | FluentMigrator |
| Android / Room | Room `Migration` objects | — |
| Flutter | drift `MigrationStrategy` | — |
| KMP / SQLDelight | `.sqm` numbered files | — |

## Naming Conventions
- Timestamp: `20240315142000_add_user_preferences.sql`
- Sequential: `0042_add_user_preferences.sql`
- Flyway: `V20240315142000__add_user_preferences.sql`
- Goose / golang-migrate: `20240315142000_add_user_preferences.up.sql` + `.down.sql`

## Key Patterns Per Tool

### Flyway
- `V{version}__{description}.sql` in `db/migration/`
- `R__{description}.sql` for repeatable scripts (views, functions, seed data)
- `spring.flyway.validate-on-migrate=true` (default — never disable)

### Alembic
- `alembic revision --autogenerate -m "description"` → **always review output before committing**
- Autogenerate misses: renamed columns, type changes requiring data conversion, triggers, stored procs
- `alembic revision -m "description"` for DML migrations (empty template)

### Prisma Migrate
- `prisma migrate dev` for local dev (creates + applies)
- `prisma migrate deploy` for production (applies pending only)
- Never edit files in `prisma/migrations/`

### Drizzle
- `drizzle-kit generate` → review generated SQL → `drizzle-kit migrate` to apply
- `drizzle-kit push` for dev only (no migration file created)

### Goose
- `goose create add_user_preferences sql` → edit Up/Down sections
- `-- +goose Up` / `-- +goose Down` markers in the SQL file
- Embed migrations: `//go:embed db/migrations/*.sql`

### golang-migrate
- Two files per migration: `000042_name.up.sql` + `000042_name.down.sql`
- `migrate -path ./db/migrations -database $DATABASE_URL up`

### EF Core
- `dotnet ef migrations add Name` → review generated C#
- `dotnet ef migrations bundle` for production — standalone binary, no EF tooling needed at deploy time
- Never `migrations remove` after pushing to a shared branch

### Room (Android)
- `@Database(version = N, exportSchema = true)` — always export schema
- `Migration(from, to)` object with `migrate()` method
- Test every migration with `MigrationTestHelper`
- **Never** `fallbackToDestructiveMigration()` in production

### drift (Flutter)
- Override `MigrationStrategy` in your database class
- `onUpgrade: (m, from, to) async { if (from < N) { ... } }`
- `dart run drift_dev schema dump` to snapshot schema for testing

### SQLDelight (KMP)
- `{version}.sqm` files in same directory as `.sq` files (1.sqm, 2.sqm, ...)
- `verifyMigrations = true` in `build.gradle.kts` to validate in CI

## DML Migrations
- Always write idempotent DML: `INSERT ... ON CONFLICT DO NOTHING`
- Batch large updates to avoid lock contention: `UPDATE ... LIMIT 1000 ... LOOP`
- Deploy DML migrations in a separate step from DDL migrations
- Test DML migration on production-scale data copy before applying

## Seed Data
- Reference data (lookup tables, config): idempotent, safe in all environments
- Development seeds: realistic fake data, dev/staging only
- Test seeds: minimal, deterministic, isolated per test suite

## Schema Drift Detection
- Apply migrations to a fresh DB in CI and diff against prod schema snapshot
- Atlas: `atlas schema diff --from $PROD_DB --to $LOCAL_DB`
- Run drift detection before every production deploy

## Security
- Migration runner user should have DDL privileges only — not superuser
- Never store credentials in migration files
- Enable checksum validation (Flyway, Liquibase, Alembic all do this by default — never disable)
- Review DML migrations for unintended data access patterns
