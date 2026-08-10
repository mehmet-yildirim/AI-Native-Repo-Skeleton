Plan and execute a database migration safely. This command covers schema design, migration file generation, rollback strategy, and production deployment guidance.

Read existing schema files, ORM models, and migration history before proceeding.

---

## Step 1: Migration Context

Identify:
- **Migration type**: additive (new table/column) | destructive (drop/rename) | data transformation
- **Risk level**: Low (add nullable column) | Medium (add non-nullable, new table) | High (rename, drop, or large data transform)
- **Data volume**: How many rows are affected? (impacts execution time and downtime risk)
- **Service impact**: Zero downtime possible? Or maintenance window needed?

---

## Step 2: Schema Design

Produce the target schema change with rationale:

```sql
-- Example: new table
CREATE TABLE user_preferences (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    key         VARCHAR(100) NOT NULL,
    value       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, key)
);

-- Indexes for query patterns
CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);
```

For each design decision, explain the rationale:
- Why this data type?
- Why this indexing strategy?
- Why nullable vs. NOT NULL?

---

## Step 3: Expand-Contract Pattern (Zero-Downtime Strategy)

For any non-additive change, apply the Expand-Contract pattern:

### Phase 1 — Expand (deploy before code change)
- Add new column/table alongside old
- Old code continues to use old structure

### Phase 2 — Migrate (data transformation)
- Backfill new structure from old
- Run in batches for large tables to avoid lock contention

### Phase 3 — Contract (after code is updated)
- Remove old column/table once all code uses the new structure
- Deploy as a separate migration, separate PR

**Never drop columns or tables in the same deployment as the code that stops using them.**

---

## Step 4: Generate Migration File

Generate the migration in the project's migration format:

### Flyway (Java)
```sql
-- V20240315142000__add_user_preferences.sql
CREATE TABLE user_preferences ( ... );
CREATE INDEX ...;
```

### Alembic (Python)
```python
def upgrade() -> None:
    op.create_table('user_preferences', ...)
    op.create_index(...)

def downgrade() -> None:
    op.drop_index(...)
    op.drop_table('user_preferences')
```

### Drizzle / Prisma / EF Core / Liquibase
Generate in the appropriate format with both `up` and `down` operations.

---

## Step 5: Rollback Strategy

Every migration MUST have a rollback plan:

| Scenario | Rollback Action | Safe? |
|----------|----------------|-------|
| New table added | Drop the table | Safe |
| New nullable column | Drop the column | Safe |
| New NOT NULL column | Drop the column | Safe if data not yet written |
| Data backfill | Re-run reverse transform | Usually safe |
| Column renamed | Rename back | Only if old code is still deployed |
| Column dropped | Cannot restore (use Expand-Contract) | DANGER |

If rollback is not safe, you MUST use the Expand-Contract pattern.

---

## Step 6: ORM Model Updates

Update the ORM model / entity to reflect the schema change:
- Generate the updated model code
- Ensure types match (nullable in DB → optional in code)
- Update repository queries that are affected

---

## Step 7: Production Deployment Checklist

- [ ] Migration tested against a copy of production data
- [ ] Estimated execution time measured on production-scale data
- [ ] If execution time > 30 seconds: batching strategy in place
- [ ] Lock contention analyzed: `ALTER TABLE` on large tables requires `CONCURRENTLY` indexes
- [ ] Rollback migration written and tested
- [ ] Application code backward compatible with both old and new schema (for zero-downtime)
- [ ] Migration run order: migrate BEFORE deploying new code (for additive changes)
- [ ] Monitoring: alert if migration takes longer than expected

---

## Step 8: Batch Migration Template (for large data transforms)

```sql
-- Process in batches to avoid long-running transactions and table locks
DO $$
DECLARE
  batch_size INT := 1000;
  processed  INT := 0;
  total      INT;
BEGIN
  SELECT COUNT(*) INTO total FROM target_table WHERE condition;

  LOOP
    UPDATE target_table
    SET new_column = transform(old_column)
    WHERE id IN (
      SELECT id FROM target_table
      WHERE new_column IS NULL AND condition
      LIMIT batch_size
    );

    GET DIAGNOSTICS processed = ROW_COUNT;
    EXIT WHEN processed = 0;

    RAISE NOTICE 'Processed % rows', processed;
    PERFORM pg_sleep(0.1); -- Brief pause to reduce lock pressure
  END LOOP;
END $$;
```

---

Migration to implement: $ARGUMENTS
