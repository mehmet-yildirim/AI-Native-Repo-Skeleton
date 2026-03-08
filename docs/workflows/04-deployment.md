# Workflow: Deployment

The complete deployment workflow from code merge to production, covering strategies,
safety checks, and incident response.

## Deployment Environments

```
Developer Machine → CI (GitHub Actions) → Staging → Production
                                                  ↗
                                         (Canary) → Production
```

| Environment | Purpose | Deploy trigger | Approval |
|-------------|---------|---------------|---------|
| **Local** | Development & debugging | Manual | None |
| **CI** | Automated quality gates | Every push | None |
| **Staging** | Integration testing, demo | Merge to main | None (auto) |
| **Production** | Live users | Tagged release | Required |

## Standard Deployment Flow

### 1. Feature Merge → Staging (Automatic)

After a PR is merged to `main`:
1. CI runs full test suite (if not already passing, merge is blocked)
2. Docker image built and tagged with git SHA
3. Deployed to staging environment
4. Smoke tests run automatically
5. If smoke tests fail: rollback staging, notify team

### 2. Release Creation → Production (Manual approval)

```bash
# Create a release tag (triggers production pipeline)
git tag v1.2.3
git push origin v1.2.3

# Or via GitHub Releases UI / release-please automation
```

Pre-production checklist:
- [ ] Staging has been running successfully for N hours
- [ ] Product owner has verified the feature on staging
- [ ] `/deploy production` run to verify all pre-deploy checks
- [ ] On-call engineer available
- [ ] Rollback plan documented

## Database Migration Workflow

Database migrations require special care. Use the `/migrate` command for implementation.

### Migration deployment order (zero-downtime)

```
Step 1: Deploy migration (additive changes only)
  ↓ Application continues running on old schema
Step 2: Deploy application code
  ↓ Application uses new schema
Step 3: [After verification] Deploy cleanup migration
  ↓ Remove old columns/tables no longer needed
```

**Golden rule**: Never run destructive schema changes and code changes in the same deployment.

### Migration safety checklist
- [ ] Migration is backward compatible (old code works against new schema)
- [ ] Migration tested on production-scale data volume
- [ ] Execution time measured (> 30 seconds → batch it)
- [ ] Rollback migration written and tested
- [ ] Long-running `ALTER TABLE` uses `CONCURRENTLY` for indexes

## Deployment Strategies

### Rolling Update (default)
- Gradually replaces pods/instances; zero-downtime
- Requires: health checks properly configured; stateless application
- Kubernetes config: `maxSurge: 1, maxUnavailable: 0`

### Blue-Green
- Two identical environments; switch load balancer atomically
- Zero-risk rollback: switch back instantly
- Use for: stateful changes, major releases, high-risk deployments
- Requires: double capacity temporarily

### Canary
- Route 5–10% of traffic to new version; monitor; scale up gradually
- Automatic rollback if error rate or latency exceeds threshold
- Use for: high-traffic services, algorithm changes, personalization
- Tools: Argo Rollouts, Flagger, AWS CodeDeploy, NGINX canary

### Feature Flags
- Deploy code disabled; enable via flag without deployment
- Instant kill switch: disable flag if issues detected
- Tools: LaunchDarkly, Unleash, GrowthBook, simple env vars

## Post-Deployment Monitoring

### Immediate monitoring (0–15 minutes post-deploy)

Watch these metrics — compare to pre-deploy baseline:

| Metric | Alert threshold | Action |
|--------|----------------|--------|
| Error rate | > 1% (warning), > 5% (critical) | Rollback |
| p99 latency | > 20% above baseline | Investigate |
| Request rate | Unexpectedly low | Investigate routing |
| Memory usage | Trending up (leak) | Rollback |
| DB connection pool | Exhausted | Investigate |

### Automatic rollback triggers
Configure your deployment platform to auto-rollback if:
- Health check fails after deploy
- Error rate exceeds threshold for 5 minutes
- Latency exceeds SLA for 5 minutes

## Rollback Procedure

### Application rollback (< 5 minutes)

```bash
# Kubernetes
kubectl rollout undo deployment/app-name

# AWS ECS
aws ecs update-service --service app --task-definition app:<previous-revision>

# Docker Compose
docker-compose up -d --scale app=0
docker-compose up -d  # with previous image tag in compose file
```

### Database rollback

Only possible if:
- Rollback migration was prepared and tested
- Application code can run against the rolled-back schema

```bash
# Flyway
flyway undo

# Alembic
alembic downgrade -1

# Goose
goose down
```

**If rollback migration was not prepared**: treat as a data incident. Escalate immediately.

## Incident Response

If a deployment causes an incident:

### 1. Immediate (0–5 minutes)
- Assess severity (how many users affected? data loss?)
- If P0/P1: page on-call, start incident channel in Slack
- Initiate rollback if the issue is clearly from the deployment

### 2. Stabilize (5–30 minutes)
- Restore service (rollback or hotfix)
- Communicate status to stakeholders
- Document timeline as it happens

### 3. Root cause (post-incident)
- What failed, why, and how it got past testing
- 5 Whys analysis
- Fix the underlying gap (missing test? process? monitoring?)

### 4. Post-incident review (within 48 hours)
- Blameless postmortem document
- Action items with owners and deadlines
- Update runbook with lessons learned

## Using /deploy

For any production deployment, run first:

```
/deploy production
```

This walks through:
- Pre-deployment checklist
- Exact execution steps for this deployment
- Post-deployment monitoring plan
- Rollback procedure

Never deploy to production without completing the deploy checklist.
