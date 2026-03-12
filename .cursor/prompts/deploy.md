Prepare and verify a deployment to the specified environment. Walk through all pre-deployment checks, deployment execution, and post-deployment validation.

---

## Step 1: Deployment Context

Identify:
- **Target environment**: staging | production | canary
- **Change type**: feature | hotfix | config | dependency update
- **Risk level**: Low (config) | Medium (feature) | High (breaking change / DB migration)
- **Rollback plan**: what is the rollback procedure if this fails?

---

## Step 2: Pre-Deployment Checklist

### Code Readiness
- [ ] All CI checks passing on the target branch/tag
- [ ] PR reviewed and approved
- [ ] No unresolved comments on the PR
- [ ] Merge conflicts resolved

### Database Migrations
- [ ] Migrations are backward compatible (old code can run against new schema)
- [ ] Migration has been tested on a copy of production data (for significant changes)
- [ ] Migration execution time estimated (downtime risk?)
- [ ] Rollback migration prepared if schema change is destructive

### Configuration & Secrets
- [ ] All required environment variables set in the target environment
- [ ] New secrets added to secrets manager and referenced correctly
- [ ] No `.env` files with real values in the repository

### Dependencies
- [ ] No new HIGH/CRITICAL CVEs in production dependencies
- [ ] Third-party service changes coordinated (API version changes, rate limit increases)

### Feature Flags
- [ ] New features behind feature flags if high risk
- [ ] Feature flags configured correctly for the target environment
- [ ] Flag rollout plan documented

### Communication
- [ ] Stakeholders notified of upcoming deployment (for significant changes)
- [ ] On-call engineer aware and available
- [ ] Maintenance window scheduled if downtime expected

---

## Step 3: Deployment Execution Plan

Provide the exact sequence of steps:

```
1. [If DB migration] Run migration: <command>
   - Expected duration: X minutes
   - Verify: <check command>

2. Deploy application: <command>
   - Strategy: rolling | blue-green | canary
   - Health check URL: <url>

3. Verify deployment health:
   - Check: <health endpoint>
   - Expected response: { status: 'ok' }

4. Smoke test: <list of manual checks or automated test commands>
```

---

## Step 4: Post-Deployment Validation

### Immediate checks (0–5 minutes after deploy)
- [ ] Health endpoint returns 200: `GET /health/ready`
- [ ] Error rate stable (not spiking vs. pre-deploy baseline)
- [ ] Application logs show normal startup, no ERROR or FATAL messages
- [ ] Key user flows working (list specific flows for this release)

### Monitor for 30 minutes
- [ ] Error rate: current vs. baseline (alert if > 2x baseline)
- [ ] Latency p99: current vs. baseline (alert if > 20% degradation)
- [ ] Database connections: not exhausted
- [ ] Memory usage: not trending up (memory leak risk)

### Confirm success
- [ ] All monitored metrics stable for 30 minutes
- [ ] No new alerts triggered
- [ ] Feature owner verified the change works end-to-end

---

## Step 5: Rollback Procedure

If any post-deployment check fails, execute rollback:

```
1. Immediately: revert application to previous image/tag
   Command: <rollback command>

2. If migration was run and caused issues:
   - Execute rollback migration: <command>
   - Verify data integrity: <query>

3. Notify stakeholders of rollback and reason

4. Create incident ticket with:
   - What was deployed
   - What failed
   - Root cause hypothesis
   - Next steps
```

---

## Step 6: Deployment Record

After successful deployment, record:
```
Date: YYYY-MM-DD HH:MM UTC
Environment: staging | production
Version: v1.2.3 (git SHA: abc1234)
Deployed by: [name]
Changes: [link to PR / changelog]
Migration run: YES | NO
Issues encountered: none | [description]
Rollback executed: NO | YES (reason: ...)
```

---

**Deployment target** (environment + what is being deployed):
