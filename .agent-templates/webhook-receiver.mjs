/**
 * webhook-receiver.mjs — Jira Server Webhook Receiver
 *
 * Listens for Jira Server webhook events and triggers the autonomous agent loop.
 * See docs/agent/jira-server-setup.md § 9 for full setup instructions.
 *
 * Usage:
 *   JIRA_WEBHOOK_SECRET=<secret> WEBHOOK_PORT=3001 node .agent-templates/webhook-receiver.mjs
 *
 * Copy this file to .agent/webhook-receiver.mjs for production use.
 * The .agent/ directory is in .gitignore — copy and customize per deployment.
 */

import { createServer } from 'node:http';
import { timingSafeEqual } from 'node:crypto';
import { execSync } from 'node:child_process';
import { appendFileSync, mkdirSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------
const PORT    = parseInt(process.env.WEBHOOK_PORT ?? '3001', 10);
const SECRET  = process.env.JIRA_WEBHOOK_SECRET;
const PATH    = process.env.WEBHOOK_PATH ?? '/jira-webhook';
const LOG_DIR = resolve('.agent/audit');

// IP allowlist: add Jira Server IP(s) here for extra safety
// Set to null to skip IP validation and rely on secret only
const ALLOWED_IPS = process.env.JIRA_SERVER_IP
  ? new Set(process.env.JIRA_SERVER_IP.split(',').map(s => s.trim()))
  : null;

// Max body size: 1 MB
const MAX_BODY_BYTES = 1_000_000;

// Jira event types that trigger agent triage
const TRIGGER_EVENTS = new Set([
  'jira:issue_created',
  'jira:issue_updated',
]);

// Comment body that triggers agent resume (from escalation response)
const AGENT_COMMANDS = [
  'AGENT_RESUME',
  'AGENT_SKIP_TASK',
  'AGENT_REASSIGN',
  'AGENT_ABANDON',
  'AGENT_APPROVE_DESIGN',
  'AGENT_APPROVE_DEPLOY',
  'AGENT_REJECT',
];

// ---------------------------------------------------------------------------
// Startup validation
// ---------------------------------------------------------------------------
if (!SECRET) {
  console.error('[webhook-receiver] FATAL: JIRA_WEBHOOK_SECRET environment variable is not set.');
  console.error('  Generate a secret: node -e "console.log(require(\'crypto\').randomBytes(32).toString(\'hex\'))"');
  process.exit(1);
}

if (!existsSync(LOG_DIR)) {
  mkdirSync(LOG_DIR, { recursive: true });
}

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------
function log(entry) {
  const line = JSON.stringify({
    timestamp: new Date().toISOString(),
    pid: process.pid,
    ...entry,
  });
  const today = new Date().toISOString().split('T')[0];
  appendFileSync(`${LOG_DIR}/${today}-webhooks.jsonl`, line + '\n');
  console.log(line);
}

// ---------------------------------------------------------------------------
// Secret validation (timing-safe comparison)
// ---------------------------------------------------------------------------
function validateSecret(headerValue) {
  if (!headerValue) return false;
  try {
    const expected = Buffer.from(SECRET, 'utf8');
    const received = Buffer.from(headerValue, 'utf8');
    if (expected.length !== received.length) return false;
    return timingSafeEqual(expected, received);
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Agent command dispatcher
// ---------------------------------------------------------------------------
function dispatchCommand(command, context) {
  const { issueKey, summary = '' } = context;
  log({ event: 'dispatching_command', command, issueKey });

  try {
    // Map comment commands to agent slash commands
    let claudeCommand;
    if (command.startsWith('AGENT_RESUME')) {
      const phaseMatch = command.match(/phase=(\w+)/);
      claudeCommand = phaseMatch
        ? `/loop resume-phase ${issueKey} ${phaseMatch[1]}`
        : `/loop resume ${issueKey}`;
    } else if (command === 'AGENT_APPROVE_DESIGN') {
      claudeCommand = `/loop resume-design-approved ${issueKey}`;
    } else if (command === 'AGENT_APPROVE_DEPLOY') {
      claudeCommand = `/loop resume-deploy-approved ${issueKey}`;
    } else {
      // AGENT_ABANDON, AGENT_REASSIGN, AGENT_SKIP_TASK, AGENT_REJECT
      claudeCommand = `/escalate resolve ${issueKey} ${command}`;
    }

    execSync(`claude --headless "${claudeCommand}"`, {
      cwd: process.cwd(),
      env: process.env,
      stdio: 'inherit',
      timeout: 600_000, // 10 min max
    });

    log({ event: 'command_dispatched', command, issueKey, status: 'success' });
  } catch (err) {
    log({ event: 'command_dispatch_error', command, issueKey, error: err.message });
  }
}

// ---------------------------------------------------------------------------
// Triage dispatcher — called when a new issue is created/updated
// ---------------------------------------------------------------------------
function dispatchTriage(issueKey, summary) {
  log({ event: 'dispatching_triage', issueKey, summary });
  try {
    execSync(`claude --headless "/triage ${issueKey}: ${summary}"`, {
      cwd: process.cwd(),
      env: process.env,
      stdio: 'inherit',
      timeout: 300_000, // 5 min max for triage
    });
    log({ event: 'triage_dispatched', issueKey, status: 'success' });
  } catch (err) {
    log({ event: 'triage_dispatch_error', issueKey, error: err.message });
  }
}

// ---------------------------------------------------------------------------
// HTTP Server
// ---------------------------------------------------------------------------
const server = createServer((req, res) => {
  const clientIp = req.socket.remoteAddress?.replace('::ffff:', '');

  // ── Path check ──────────────────────────────────────────────────────────
  if (req.method !== 'POST' || req.url !== PATH) {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not Found');
    return;
  }

  // ── IP allowlist ─────────────────────────────────────────────────────────
  if (ALLOWED_IPS && !ALLOWED_IPS.has(clientIp)) {
    log({ event: 'webhook_rejected', reason: 'ip_not_allowed', clientIp });
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    res.end('Forbidden');
    return;
  }

  // ── Secret validation ────────────────────────────────────────────────────
  const secretHeader = req.headers['x-jira-secret'];
  if (!validateSecret(secretHeader)) {
    log({ event: 'webhook_rejected', reason: 'invalid_secret', clientIp });
    res.writeHead(401, { 'Content-Type': 'text/plain' });
    res.end('Unauthorized');
    return;
  }

  // ── Body collection ──────────────────────────────────────────────────────
  let body = '';
  let bodyBytes = 0;

  req.on('data', (chunk) => {
    bodyBytes += chunk.length;
    if (bodyBytes > MAX_BODY_BYTES) {
      log({ event: 'webhook_rejected', reason: 'body_too_large', clientIp });
      res.writeHead(413);
      res.end('Payload Too Large');
      req.destroy();
      return;
    }
    body += chunk;
  });

  req.on('end', () => {
    let payload;
    try {
      payload = JSON.parse(body);
    } catch {
      log({ event: 'webhook_rejected', reason: 'invalid_json', clientIp });
      res.writeHead(400);
      res.end('Bad Request');
      return;
    }

    const { webhookEvent, issue, comment } = payload;
    const issueKey  = issue?.key;
    const summary   = issue?.fields?.summary ?? '';
    const issueStatus = issue?.fields?.status?.name ?? '';

    log({ event: 'webhook_received', webhookEvent, issueKey, issueStatus, clientIp });

    // ── Respond immediately (Jira expects fast ack) ───────────────────────
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ received: true, issueKey, webhookEvent }));

    // ── Handle event async (after response sent) ─────────────────────────
    setImmediate(() => {
      // Issue created or updated → triage
      if (TRIGGER_EVENTS.has(webhookEvent) && issueKey) {
        // Skip issues already being processed by the agent
        const skipLabels = ['agent-accepted', 'agent-in-progress', 'agent-done', 'agent-rejected'];
        const labels = (issue?.fields?.labels ?? []).map(l => l.name ?? l);
        if (labels.some(l => skipLabels.includes(l))) {
          log({ event: 'webhook_skipped', reason: 'already_processed', issueKey, labels });
          return;
        }
        dispatchTriage(issueKey, summary);
      }

      // Comment added → check for AGENT_* commands
      if (webhookEvent === 'comment_created' && issueKey && comment?.body) {
        const commentBody = comment.body.trim();
        const matchedCommand = AGENT_COMMANDS.find(cmd => commentBody.startsWith(cmd));
        if (matchedCommand) {
          dispatchCommand(commentBody, { issueKey, summary });
        }
      }
    });
  });

  req.on('error', (err) => {
    log({ event: 'request_error', error: err.message, clientIp });
  });
});

server.on('error', (err) => {
  log({ event: 'server_error', error: err.message });
  process.exit(1);
});

server.listen(PORT, '0.0.0.0', () => {
  log({
    event: 'webhook_receiver_started',
    port: PORT,
    path: PATH,
    ipAllowlistEnabled: ALLOWED_IPS !== null,
    allowedIps: ALLOWED_IPS ? [...ALLOWED_IPS] : 'all',
  });
  console.log(`\nJira Server webhook receiver ready`);
  console.log(`  Listening : 0.0.0.0:${PORT}${PATH}`);
  console.log(`  Secret    : configured (${SECRET.length} chars)`);
  console.log(`  IP check  : ${ALLOWED_IPS ? [...ALLOWED_IPS].join(', ') : 'disabled'}`);
  console.log(`  Log dir   : ${LOG_DIR}\n`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  log({ event: 'webhook_receiver_stopping', reason: 'SIGTERM' });
  server.close(() => process.exit(0));
});
process.on('SIGINT', () => {
  log({ event: 'webhook_receiver_stopping', reason: 'SIGINT' });
  server.close(() => process.exit(0));
});
