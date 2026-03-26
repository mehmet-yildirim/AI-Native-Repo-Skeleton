# Containerized Agent — Setup Guide

Run the Initium autonomous agent as a long-lived Docker container. The image bakes in the full Initium runtime (slash commands, hooks, rules); your project source code is never bundled — it is cloned from `GIT_REPO_URL` at container startup.

Two trigger modes are available — use one or both:

| Mode | Service | How it works |
|------|---------|--------------|
| **Polling** | `agent` | Always runs cron on `GROOM_CRON` schedule |
| **Event-driven** | `webhook` | Starts webhook receiver if `JIRA_WEBHOOK_SECRET` is set; **falls back to cron polling automatically** if not |

Both services are self-contained — each clones the repository and overlays Initium tooling independently. Running them together is safe: the webhook service handles real-time events while the agent service acts as a catch-up sweep for anything missed.

---

## How It Works

```
Container startup
  │
  ├─ 1. Validate required env vars (AI provider + GIT_REPO_URL)
  ├─ 2. Configure git identity and credential helper
  ├─ 3. Clone GIT_REPO_URL → /workspace  (or git pull if already cloned)
  ├─ 4. Overlay Initium tooling if absent in the workspace:
  │      .claude/  ·  .cursor/  ·  .continue/  ·  agent.config.yaml
  ├─ 5. Export env vars to /etc/environment (so cron jobs can read them)
  ├─ 6. Write /etc/cron.d/initium-agent with GROOM_CRON schedule
  └─ 7. Start cron daemon · tail /var/log/groom.log
              │
              └─ On each cron tick:
                   ├─ Check .agent/STOP kill switch
                   ├─ git pull --rebase origin/<branch>
                   ├─ claude --dangerously-skip-permissions -p "/groom"
                   └─ git push (if agent created commits)
```

**Tooling overlay** — if `.claude/`, `.cursor/`, `.continue/`, or `agent.config.yaml` already exist in the cloned repo (i.e., the project was initialized with `/init`), they are used as-is. The image copy is applied only when the directory or file is absent.

---

## Quick Start

### Polling only (cron-based)

```bash
cp .initium/docker/.env.example .initium/docker/.env
$EDITOR .initium/docker/.env   # fill in GIT_REPO_URL, AI provider, JIRA creds

docker compose -f .initium/docker/docker-compose.yml up -d --build agent
docker logs -f initium-agent
```

### Polling + webhook receiver

```bash
cp .initium/docker/.env.example .initium/docker/.env
$EDITOR .initium/docker/.env   # also set JIRA_WEBHOOK_SECRET

docker compose -f .initium/docker/docker-compose.yml up -d --build
docker logs -f initium-agent    # cron runner
docker logs -f initium-webhook  # webhook receiver

# Point your Jira Server webhook at:
#   http://<host>:3001/jira-webhook
# Header: X-Jira-Secret: <JIRA_WEBHOOK_SECRET>
```

---

## Environment Variables

### Required

| Variable | Description |
|----------|-------------|
| `GIT_REPO_URL` | Full HTTPS clone URL of the repo to work on. For private repos embed the token: `https://x-token:<GITHUB_TOKEN>@github.com/org/repo.git` |
| One AI provider group (see below) | Credentials for the AI backend |

### AI CLI

| Variable | Default | Description |
|----------|---------|-------------|
| `AGENT_CLI` | `claude` | Which CLI executes the agent workflows. See table below. |

| Value | CLI | How /groom is invoked | Reads rules from |
|-------|-----|-----------------------|-----------------|
| `claude` | Claude Code | `claude --dangerously-skip-permissions -p "/groom"` | `.claude/commands/` |
| `cursor` | Cursor CLI | `cursor --print --force "$(cat .claude/commands/groom.md)"` | `.cursor/rules/` |

> Both CLIs are installed in the image. Switch between them with `AGENT_CLI` — no rebuild required.

### AI Provider — choose one

**Option A: Anthropic (direct)**

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Your Anthropic API key (`sk-ant-…`) |

**Option B: AWS Bedrock**

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_USE_BEDROCK` | Set to `1` |
| `AWS_ACCESS_KEY_ID` | IAM access key |
| `AWS_SECRET_ACCESS_KEY` | IAM secret |
| `AWS_SESSION_TOKEN` | Only if using temporary credentials |
| `AWS_REGION` | e.g. `us-east-1` |

**Option C: Google Vertex AI**

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_USE_VERTEX` | Set to `1` |
| `CLOUD_ML_REGION` | e.g. `us-east5` |
| `ANTHROPIC_VERTEX_PROJECT_ID` | Your GCP project ID |

For Vertex, mount your service account JSON via the `volumes` section in `docker-compose.yml`:
```yaml
volumes:
  - /path/to/gcp-key.json:/run/secrets/gcp-key.json:ro
```
And set `GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/gcp-key.json` in the environment.

### Issue Tracker

| Variable | Description |
|----------|-------------|
| `JIRA_URL` | e.g. `https://yourcompany.atlassian.net` |
| `JIRA_EMAIL` | Atlassian account email |
| `JIRA_API_TOKEN` | Jira API token |
| `LINEAR_API_KEY` | Linear API key (alternative to JIRA) |

### Git Hosting

| Variable | Description |
|----------|-------------|
| `GITHUB_TOKEN` | Personal access token — used for PR creation and HTTPS git auth |
| `GITLAB_TOKEN` | GitLab personal access token (alternative to GitHub) |
| `GIT_BRANCH` | Branch to clone and push to (default: `main`) |
| `GIT_AUTHOR_NAME` | Commit author name (default: `Initium Agent`) |
| `GIT_AUTHOR_EMAIL` | Commit author email (default: `agent@noreply.local`) |
| `GIT_CLONE_DEPTH` | Shallow clone depth (default: `50`) |

### Notifications

| Variable | Description |
|----------|-------------|
| `SLACK_BOT_TOKEN` | Slack bot token for escalation notifications |
| `SLACK_TEAM_ID` | Slack workspace ID |

### Passthrough

| Variable | Description |
|----------|-------------|
| `CURSOR_API_KEY` | Cursor API key — passed through to workspace tooling that uses Cursor's BYOK. The agent runtime itself uses Claude Code CLI, not Cursor. |

### Schedule (`agent` service)

| Variable | Default | Description |
|----------|---------|-------------|
| `GROOM_CRON` | `*/15 * * * *` | Standard cron expression controlling how often `/groom` runs. Matches `agent.config.yaml → poll_interval_minutes: 15`. |

**Schedule examples:**

```bash
GROOM_CRON=*/30 * * * *      # every 30 minutes
GROOM_CRON=0 9-17 * * 1-5   # hourly during business hours, weekdays
GROOM_CRON=0 8 * * 1         # once a week, Monday at 08:00
```

### Webhook (`webhook` service)

| Variable | Default | Description |
|----------|---------|-------------|
| `JIRA_WEBHOOK_SECRET` | **required** | Shared secret sent by Jira Server in the `X-Jira-Secret` header. Generate: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` |
| `WEBHOOK_PORT` | `3001` | Port the receiver listens on |
| `WEBHOOK_PATH` | `/jira-webhook` | URL path Jira Server posts to |
| `JIRA_SERVER_IP` | _(unset)_ | Comma-separated IP allowlist. When unset, any IP is accepted (secret-only validation). |

---

## Volumes

| Volume | Mount | Purpose |
|--------|-------|---------|
| `workspace` | `/workspace` | Cloned project repository — persisted across restarts so the container resumes without re-cloning |
| `agent-state` | `/initium/.agent` | Audit logs, task state, pipeline outputs — persisted for crash recovery and history |

---

## Webhook Receiver Architecture

The `webhook` service starts `webhook-receiver.mjs` (deployed from `.agent-templates/` on first run) and listens for Jira Server POST events:

```
Jira Server
  │  POST /jira-webhook
  │  X-Jira-Secret: <secret>
  ▼
webhook container (port 3001)
  ├─ IP allowlist check  (JIRA_SERVER_IP)
  ├─ Secret validation   (timing-safe compare)
  ├─ ACK 200 immediately (Jira expects fast response)
  └─ Handle async:
       jira:issue_created / jira:issue_updated
         → skip if already labelled agent-accepted/in-progress/done
         → claude -p "/triage <issue-key>: <summary>"

       comment_created with AGENT_* command
         → AGENT_RESUME           → /loop resume <issue-key>
         → AGENT_APPROVE_DESIGN   → /loop resume-design-approved <issue-key>
         → AGENT_APPROVE_DEPLOY   → /loop resume-deploy-approved <issue-key>
         → AGENT_ABANDON / AGENT_REJECT / AGENT_SKIP_TASK
                                  → /escalate resolve <issue-key> <command>
```

**Jira Server webhook configuration** — in Jira Server admin:
- URL: `http://<docker-host>:3001/jira-webhook`
- Events: `Issue Created`, `Issue Updated`, `Comment Created`
- Custom header: `X-Jira-Secret: <JIRA_WEBHOOK_SECRET>`

For full Jira Server admin setup see [jira-server-setup.md](jira-server-setup.md).

> **Production note:** Put a TLS-terminating reverse proxy (nginx, Caddy) in front of the webhook port. Never expose port 3001 directly to the internet without TLS.

---

## Polling vs. Webhook — When to use each

| | Polling (`agent`) | Webhook (`webhook`) |
|---|---|---|
| **Trigger** | Time-based (cron) | Event-based (Jira push) |
| **Latency** | Up to `GROOM_CRON` interval | Near-instant |
| **Works with** | Jira Cloud + Jira Server | Jira Server only (Cloud uses polling) |
| **Network requirement** | Outbound only | Jira Server must reach the container |
| **Fallback** | — | Cron polling if `JIRA_WEBHOOK_SECRET` unset |
| **Complexity** | Minimal | Requires exposed port + TLS in prod |

### Decision guide

```
Is JIRA_WEBHOOK_SECRET configured?
  No  → webhook service silently falls back to cron (same as agent service)
  Yes → Is Jira Server able to reach the container?
          No  → webhook service falls back to cron automatically
          Yes → event-driven mode active; run agent alongside for catch-up
```

---

## Operations

### Stopping and resuming

```bash
# Stop (state is preserved in volumes)
docker compose -f .initium/docker/docker-compose.yml stop

# Resume
docker compose -f .initium/docker/docker-compose.yml start
```

### Emergency kill switch

Create `.agent/STOP` inside the workspace to halt the agent without stopping the container. The runner script checks for this file before every `/groom` invocation.

```bash
# Halt agent runs
docker exec initium-agent touch /workspace/.agent/STOP

# Re-enable
docker exec initium-agent rm /workspace/.agent/STOP
```

### Viewing logs

```bash
# Live agent log (groom runs)
docker logs -f initium-agent

# Audit trail (one JSON line per agent decision)
docker exec initium-agent cat /workspace/.agent/audit/$(date +%Y-%m-%d)-decisions.jsonl
```

### Forcing an immediate groom run

```bash
docker exec initium-agent /groom-runner.sh
```

### Viewing webhook logs

```bash
docker logs -f initium-webhook

# Webhook audit trail (one JSON line per event)
docker exec initium-webhook cat /workspace/.agent/audit/$(date +%Y-%m-%d)-webhooks.jsonl
```

### Testing the webhook endpoint

```bash
# Send a synthetic issue_created event
curl -s -X POST http://localhost:3001/jira-webhook \
  -H "Content-Type: application/json" \
  -H "X-Jira-Secret: <your-secret>" \
  -d '{
    "webhookEvent": "jira:issue_created",
    "issue": {
      "key": "PROJ-99",
      "fields": { "summary": "Test webhook delivery", "labels": [], "status": { "name": "To Do" } }
    }
  }'
# Expected: {"received":true,"issueKey":"PROJ-99","webhookEvent":"jira:issue_created"}
```

### Rebuilding after Initium updates

```bash
docker compose -f .initium/docker/docker-compose.yml build --no-cache
docker compose -f .initium/docker/docker-compose.yml up -d
```

---

## Security Notes

- **No secrets in the image.** All credentials are injected at runtime via environment variables — never baked into the image layer.
- **`--dangerously-skip-permissions`** is required for unattended operation. The agent's blast radius is constrained by `agent.config.yaml` (`forbidden_commands`, `protected_paths`, `max_files_per_pr`) and `.claude/settings.json`.
- **Private repos** — embed the token in `GIT_REPO_URL`, or use the `GITHUB_TOKEN` / `GITLAB_TOKEN` credential helper configured by the entrypoint.
- **GCP service account keys** — mount as a read-only volume secret, never set the key contents as an env var.

---

## Troubleshooting

**Container exits immediately**
Check that `GIT_REPO_URL` and at least one AI provider credential are set. The entrypoint validates these and exits with an error message if missing.

**"No .claude/commands found" warning at startup**
Expected for repos not yet initialized with Initium. The entrypoint overlays the defaults automatically — no action needed.

**`/groom` runs but JIRA returns no issues**
Verify `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` are correct, and that `agent.config.yaml → issue_tracker.jira.backlog_jql` matches issues in your project.

**Git push fails**
Ensure `GITHUB_TOKEN` (or `GITLAB_TOKEN`) has `repo` write scope, or embed the token directly in `GIT_REPO_URL`.

**Cron never fires**
Check the cron syntax in `GROOM_CRON` — the field must be a valid 5-part cron expression. Run `docker exec initium-agent crontab -l` to verify what was registered.

**Webhook returns 401**
`X-Jira-Secret` header value does not match `JIRA_WEBHOOK_SECRET`. Verify both sides use the same string with no trailing whitespace.

**Webhook returns 403**
The source IP is not in `JIRA_SERVER_IP`. Either add the Jira Server IP or unset `JIRA_SERVER_IP` to rely on secret-only validation.

**`webhook` service exits immediately**
`JIRA_WEBHOOK_SECRET` is not set. Check `docker logs initium-webhook` for the error message.

**Webhook service starts but no triage runs**
The issue may already carry an `agent-accepted` / `agent-in-progress` / `agent-done` label — the receiver skips issues it has already processed. Remove the label in Jira to re-trigger.
